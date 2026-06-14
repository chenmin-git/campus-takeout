<template>
  <div class="amap-wrap">
    <div ref="mapEl" class="amap-box"></div>
    <div v-if="error" class="amap-error">
      <div class="amap-error-title">地图暂未配置</div>
      <div class="amap-error-desc">请填写高德 JSAPI Key 与安全密钥</div>
      <a href="https://console.amap.com/dev/key/app" target="_blank">去申请</a>
      <van-button size="mini" round color="#ff6b35" @click="showConfig = true">手动填写</van-button>
    </div>

    <van-dialog
      v-model:show="showConfig"
      title="配置高德地图"
      show-cancel-button
      confirm-button-text="保存并重试"
      @confirm="saveConfig"
    >
      <div class="config-form">
        <van-field v-model="form.key" label="Key" placeholder="填写高德 JSAPI Key" />
        <van-field v-model="form.security" label="安全密钥" placeholder="填写 Security JS Code" />
        <div class="config-link">
          申请地址：<a href="https://console.amap.com/dev/key/app" target="_blank">高德开放平台</a>
        </div>
      </div>
    </van-dialog>
  </div>
</template>

<script>
import { reactive, ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { showToast } from 'vant'
import { loadAMap, mockPoint } from '../utils/amap'

// 配送地图组件：展示「商家 → 收货地址」两点并规划驾车路线。
// seed 用于在无真实经纬度时生成稳定的演示坐标。
export default {
  name: 'AMapView',
  props: {
    seed: { type: [Number, String], default: 1 },
    shopName: { type: String, default: '商家' },
    destName: { type: String, default: '收货地址' }
  },
  setup(props) {
    const mapEl = ref(null)
    const error = ref(false)
    const showConfig = ref(false)
    const form = reactive({
      key: localStorage.getItem('amap_key') || '',
      security: localStorage.getItem('amap_security') || ''
    })
    let map = null
    let AMapRef = null

    const render = async () => {
      try {
        error.value = false
        const AMap = await loadAMap()
        AMapRef = AMap
        if (!mapEl.value) return
        // 商家点与目的地点：用不同 seed 偏移，保证两点分离
        const shopPos = mockPoint(Number(props.seed) + 7)
        const destPos = mockPoint(Number(props.seed) + 88)
        if (map) {
          map.destroy()
          map = null
        }
        map = new AMap.Map(mapEl.value, {
          zoom: 14,
          center: shopPos
        })
        const shopMarker = new AMap.Marker({
          position: shopPos,
          title: props.shopName,
          label: { content: props.shopName, direction: 'top' }
        })
        const destMarker = new AMap.Marker({
          position: destPos,
          title: props.destName,
          label: { content: props.destName, direction: 'top' }
        })
        map.add([shopMarker, destMarker])
        // 规划驾车路线，画出配送路径
        const driving = new AMap.Driving({ map, hideMarkers: true, showTraffic: false })
        driving.search(shopPos, destPos, () => {
          map.setFitView()
        })
      } catch (e) {
        error.value = true
      }
    }

    const saveConfig = () => {
      if (!form.key.trim() || !form.security.trim()) {
        showToast('请填写完整地图配置')
        return false
      }
      localStorage.setItem('amap_key', form.key.trim())
      localStorage.setItem('amap_security', form.security.trim())
      showToast('已保存，正在重试')
      render()
      return true
    }

    onMounted(render)
    watch(() => props.seed, render)
    // 组件卸载时销毁地图，避免重复初始化与内存泄漏
    onBeforeUnmount(() => {
      if (map) {
        map.destroy()
        map = null
      }
    })

    return { mapEl, error, showConfig, form, saveConfig }
  }
}
</script>

<style scoped>
.amap-wrap {
  position: relative;
}
.amap-box {
  width: 100%;
  height: 220px;
  border-radius: 10px;
  overflow: hidden;
}
.amap-error {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 7px;
  color: #969799;
  font-size: 13px;
  background: #f7f8fa;
  border-radius: 10px;
  text-align: center;
}
.amap-error-title {
  color: #333;
  font-weight: 700;
}
.amap-error a,
.config-link a {
  color: #ff6b35;
}
.config-form {
  padding: 12px 8px 4px;
}
.config-link {
  padding: 8px 16px 12px;
  font-size: 12px;
  color: #666;
}
</style>
