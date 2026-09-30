import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    // Same-origin in dev so the Spring session cookie just works.
    proxy: { '/api': 'http://localhost:8080' }
  },
  build: {
    // Bundled into the Spring Boot jar, served from the backend's static/.
    outDir: '../backend/src/main/resources/static',
    emptyOutDir: true
  }
});
