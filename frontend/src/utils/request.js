import axios from 'axios'
import { showToast } from 'vant'
import router from '../router'
import { useUserStore } from '../store/user'

// 统一 axios 实例：自动携带 token，统一处理后端 Result 结构与异常
const request = axios.create({
  baseURL: '/api',
  timeout: 15000
})

// 请求拦截：附加登录 token
request.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.token = token
  }
  return config
})

// 响应拦截：解析后端统一响应，401 跳登录，业务异常弹中文提示
request.interceptors.response.use(
  (response) => {
    const res = response.data
    if (res.code === 200) {
      return res
    }
    showToast(res.message || '操作失败')
    return Promise.reject(res)
  },
  (error) => {
    if (error.response && error.response.status === 401) {
      const userStore = useUserStore()
      userStore.logout()
      showToast('登录已过期，请重新登录')
      router.replace('/login')
    } else {
      showToast('网络异常，请稍后重试')
    }
    return Promise.reject(error)
  }
)

export default request

// 拼接图片完整地址：数据库存相对路径（uploads/...），通过 vite 代理访问
export function imgUrl(path) {
  if (!path) return ''
  if (path.startsWith('http')) return path
  return '/' + path
}
