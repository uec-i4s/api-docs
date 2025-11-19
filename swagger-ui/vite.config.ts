import { defineConfig } from 'vite'

export default defineConfig({
  base: "/swagger-ui/",
  preview: {
    host: true,
    port: 8001,
  }
})
