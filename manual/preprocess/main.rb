# frozen_string_literal: true

require 'json'
require 'English'

# Set default encodings for I/O
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Handle the "supports" query - check if we support the given renderer
if ARGV.any? && ARGV[0] == 'supports'
  # We support html and markdown renderers
  # Exit with 0 for success
  exit 0
end

def process_chapter(chapter)
  return chapter unless chapter['content']

  content = chapter['content']
  lines = content.lines
  processed_lines = []

  lines.each do |line|
    match = line.match(/<!--\s*preprocess:\s*(?<cmdname>\S+)\s*(?<args>.*?)\s*-->/)
    if match
      cmdname = match[:cmdname]
      args = match[:args]

      # Call the command script (convert hyphens to underscores for filename)
      script_path = File.join(File.dirname(__FILE__), "#{cmdname.tr('-', '_')}.rb")
      if File.exist?(script_path)
        begin
          output = `ruby "#{script_path}" #{args} 2>&1`
          if $CHILD_STATUS.success?
            processed_lines << output
          else
            warn "Error: Failed to execute #{cmdname}: #{output}"
            processed_lines << "<!-- Error running #{cmdname}: see stderr for details -->\n"
          end
        rescue StandardError => e
          warn "Error: Exception in #{cmdname}: #{e.message}"
          processed_lines << "<!-- Error: #{e.message} -->\n"
        end
      else
        warn "Warn: Unknown preprocess command: #{cmdname}"
        processed_lines << "<!-- Unknown preprocess command: #{cmdname} -->\n"
      end
    else
      processed_lines << line
    end
  end

  chapter['content'] = processed_lines.join

  # Process sub-items recursively
  if chapter['sub_items']
    chapter['sub_items'] = chapter['sub_items'].map do |item|
      if item['Chapter']
        { 'Chapter' => process_chapter(item['Chapter']) }
      else
        item
      end
    end
  end

  chapter
end

# Read input from stdin
input = STDIN.read

# If no input, exit
if input.strip.empty?
  warn 'No input provided'
  exit 1
end

# Parse JSON input
begin
  data = JSON.parse(input)
rescue JSON::ParserError => e
  warn "Failed to parse JSON: #{e.message}"
  warn "Input: #{input[0..200]}"
  exit 1
end

_context = data[0]
book = data[1]

# Process all sections
book['sections'] = book['sections'].map do |section|
  if section['Chapter']
    { 'Chapter' => process_chapter(section['Chapter']) }
  else
    section
  end
end

# Output the modified book (just the book, not the context)
puts JSON.generate(book)
