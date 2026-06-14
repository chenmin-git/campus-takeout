import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// H5 移动端，开发端口 5175，接口与上传图片代理到后端 8090
export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5175,
    host: '0.0.0.0',
    // 允许通过任意域名访问（内网穿透/公网代理演示时，避免 Vite 拦截外部 Host）
    allowedHosts: true,
    proxy: {
      '/api': {
        target: 'http://localhost:8090',
        changeOrigin: true
      },
      '/uploads': {
        target: 'http://localhost:8090',
        changeOrigin: true
      }
    }
  }
})
