# frozen_string_literal: true

require 'yaml'

# Get the filename from command line argument
if ARGV.empty?
  warn 'Usage: list_endpoint.rb <spec-filename>'
  exit 1
end

spec_filename = ARGV[0]

# Find the spec file in specs-src directory (symlink in local dev, copied in Nix build)
script_dir = File.dirname(__FILE__)
spec_path = File.join(script_dir, 'specs-src', spec_filename)

unless File.exist?(spec_path)
  warn "Error: Spec file not found: #{spec_path}"
  exit 1
end

# Load the YAML spec
begin
  spec = YAML.load_file(spec_path)
rescue StandardError => e
  warn "Error parsing YAML: #{e.message}"
  exit 1
end

# Extract paths and generate markdown table
paths = spec['paths'] || {}

if paths.empty?
  puts 'No endpoints found.'
  exit 0
end

# Generate markdown table
puts '| Method | Path | Summary |'
puts '|--------|------|---------|'

paths.keys.sort.each do |path|
  methods = paths[path]
  methods.each do |method, details|
    next if method.start_with?('$') # Skip special keys like $ref
    next unless details.is_a?(Hash) # Only process method definitions

    method_upper = method.upcase
    summary = details['summary'] || ''

    puts "| #{method_upper} | `#{path}` | #{summary} |"
  end
end
