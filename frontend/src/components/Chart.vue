<template>
  <div ref="el" class="chart"></div>
</template>

<script>
import * as echarts from 'echarts'
import { onMounted, onBeforeUnmount, ref, watch, nextTick } from 'vue'

// 通用 ECharts 容器：监听窗口缩放自适应，组件卸载时销毁实例避免重复初始化报错
export default {
  name: 'Chart',
  props: {
    option: { type: Object, required: true }
  },
  setup(props) {
    const el = ref(null)
    let chart = null

    const render = () => {
      if (!el.value) return
      if (!chart) {
        chart = echarts.init(el.value)
      }
      chart.setOption(props.option, true)
    }

    const resize = () => chart && chart.resize()

    onMounted(() => {
      nextTick(render)
      window.addEventListener('resize', resize)
    })

    watch(() => props.option, () => nextTick(render), { deep: true })

    onBeforeUnmount(() => {
      window.removeEventListener('resize', resize)
      if (chart) {
        chart.dispose()
        chart = null
      }
    })

    return { el }
  }
}
</script>
