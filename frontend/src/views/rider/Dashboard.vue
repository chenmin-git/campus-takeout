<template>
  <div class="page">
    <van-nav-bar title="骑手工作台" />

    <div class="stat-grid">
      <div class="stat-card">
        <div class="num">{{ stats.availableCount || 0 }}</div>
        <div class="label">可抢订单</div>
      </div>
      <div class="stat-card">
        <div class="num">{{ stats.deliveringCount || 0 }}</div>
        <div class="label">配送中</div>
      </div>
      <div class="stat-card">
        <div class="num">{{ stats.todayFinished || 0 }}</div>
        <div class="label">今日完成</div>
      </div>
      <div class="stat-card">
        <div class="num">¥{{ Number(stats.income || 0).toFixed(2) }}</div>
        <div class="label">累计配送收入</div>
      </div>
    </div>

    <van-cell-group inset style="margin: 12px 0">
      <van-cell title="累计完成订单" :value="(stats.finishedCount || 0) + ' 单'" />
      <van-cell title="去抢单大厅" is-link @click="$router.push('/r/hall')" />
      <van-cell title="我的配送订单" is-link @click="$router.push('/r/orders')" />
    </van-cell-group>

    <div class="chart-box">
      <div class="chart-title">近 6 个月完成单量</div>
      <Chart :option="finishOption" />
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import Chart from '../../components/Chart.vue'
import { statsApi } from '../../api'

export default {
  name: 'RiderDashboard',
  components: { Chart },
  setup() {
    const stats = ref({})

    const finishOption = computed(() => ({
      tooltip: { trigger: 'axis' },
      grid: { left: 36, right: 16, top: 20, bottom: 30 },
      xAxis: { type: 'category', data: stats.value.months || [] },
      yAxis: { type: 'value', minInterval: 1 },
      series: [
        {
          name: '完成单量',
          type: 'bar',
          barWidth: '46%',
          itemStyle: { color: '#ff6b35', borderRadius: [4, 4, 0, 0] },
          data: stats.value.finishTrend || []
        }
      ]
    }))

    onMounted(async () => {
      const { data } = await statsApi.rider()
      stats.value = data
    })

    return { stats, finishOption }
  }
}
</script>

<style scoped>
.chart-box {
  margin-top: 4px;
}
</style>
