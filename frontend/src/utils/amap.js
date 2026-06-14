// 高德地图 JSAPI 封装：统一加载入口，避免每个页面重复初始化。
// 说明：地图为在线地理服务，瓦片与 JS 由高德服务器提供，属功能必需的外部依赖；
// 仅地图能力使用在线服务，其余静态资源（图标、字体、演示图片）仍全部本地化。
import AMapLoader from '@amap/amap-jsapi-loader'

// JSAPI Key 与安全密钥（Web端）。环境变量优先，未配置时允许演示用户在前台临时填写。
const getAmapConfig = () => ({
  key: import.meta.env.VITE_AMAP_KEY || localStorage.getItem('amap_key') || '',
  security: import.meta.env.VITE_AMAP_SECURITY || localStorage.getItem('amap_security') || ''
})

// 演示用校园中心坐标（杭州），无真实经纬度的地址在此基础上做小幅偏移定位
export const CAMPUS_CENTER = [120.1614, 30.2741]

let amapPromise = null

// 加载高德 JSAPI（单例），返回全局 AMap 对象
export function loadAMap() {
  if (amapPromise) return amapPromise
  const { key, security } = getAmapConfig()
  if (!key || !security) {
    return Promise.reject(new Error('请先配置 VITE_AMAP_KEY 和 VITE_AMAP_SECURITY'))
  }
  window._AMapSecurityConfig = { securityJsCode: security }
  amapPromise = AMapLoader.load({
    key,
    version: '2.0',
    plugins: ['AMap.Geocoder', 'AMap.Driving']
  })
  return amapPromise
}

// 由订单/地址 ID 生成稳定的演示坐标偏移，保证同一条数据每次定位一致
export function mockPoint(seed, base = CAMPUS_CENTER) {
  const n = Number(seed) || 0
  const dx = (((n * 37) % 100) - 50) / 1000
  const dy = (((n * 53) % 100) - 50) / 1000
  return [base[0] + dx, base[1] + dy]
}
