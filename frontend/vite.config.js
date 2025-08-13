import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    host: '0.0.0.0',  // Permitir acesso externo
    port: 3000,        // Usar porta 3000
    strictPort: true,  // Forçar porta específica
    watch: {
      usePolling: true // Necessário para Docker
    }
  }
})