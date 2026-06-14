<template>
  <div class="page">
    <van-nav-bar title="我的工作台" left-arrow @click-left="$router.back()" />

    <div class="stat-grid">
      <div class="stat-card">
        <div class="num">{{ stats.orderCount || 0 }}</div>
        <div class="label">累计订单</div>
      </div>
      <div class="stat-card">
        <div class="num">¥{{ Number(stats.totalSpent || 0).toFixed(2) }}</div>
        <div class="label">累计消费</div>
      </div>
      <div class="stat-card">
        <div class="num">{{ stats.finishedCount || 0 }}</div>
        <div class="label">已完成</div>
      </div>
      <div class="stat-card">
        <div class="num">{{ stats.ongoingCount || 0 }}</div>
        <div class="label">进行中</div>
      </div>
    </div>

    <div class="chart-box">
      <div class="chart-title">近 6 个月消费趋势</div>
      <Chart :option="spentOption" />
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import Chart from '../../components/Chart.vue'
import { statsApi } from '../../api'

export default {
  name: 'UserDashboard',
  components: { Chart },
  setup() {
    const stats = ref({})

    const spentOption = computed(() => ({
      tooltip: { trigger: 'axis' },
      grid: { left: 40, right: 16, top: 20, bottom: 30 },
      xAxis: { type: 'category', data: stats.value.months || [] },
      yAxis: { type: 'value' },
      series: [
        {
          name: '消费金额',
          type: 'line',
          smooth: true,
          areaStyle: { color: 'rgba(255,107,53,.15)' },
          itemStyle: { color: '#ff6b35' },
          data: (stats.value.spentTrend || []).map((v) => Number(v))
        }
      ]
    }))

    onMounted(async () => {
      const { data } = await statsApi.user()
      stats.value = data
    })

    return { stats, spentOption }
  }
}
</script>
