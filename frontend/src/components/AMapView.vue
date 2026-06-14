<template>
  <div class="amap-wrap">
    <div ref="mapEl" class="amap-box"></div>
    <div v-if="error" class="amap-error">地图加载失败，请检查网络</div>
  </div>
</template>

<script>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
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
    let map = null
    let AMapRef = null

    const render = async () => {
      try {
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

    onMounted(render)
    watch(() => props.seed, render)
    // 组件卸载时销毁地图，避免重复初始化与内存泄漏
    onBeforeUnmount(() => {
      if (map) {
        map.destroy()
        map = null
      }
    })

    return { mapEl, error }
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
  align-items: center;
  justify-content: center;
  color: #969799;
  font-size: 13px;
  background: #f7f8fa;
  border-radius: 10px;
}
</style>
