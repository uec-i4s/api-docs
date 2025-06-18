import { defineConfig } from 'vite'

export default defineConfig({
  base: "/docs/swagger-ui/",
  preview: {
    host: true,
    port: 8001,
  }
})
