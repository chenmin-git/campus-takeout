<template>
  <div class="page">
    <van-nav-bar title="平台工作台" />

    <div class="stat-grid">
      <div class="stat-card">
        <div class="num">{{ stats.userCount || 0 }}</div>
        <div class="label">用户数</div>
      </div>
      <div class="stat-card">
        <div class="num">{{ stats.shopCount || 0 }}</div>
        <div class="label">店铺数</div>
      </div>
      <div class="stat-card">
        <div class="num">{{ stats.orderCount || 0 }}</div>
        <div class="label">订单数</div>
      </div>
      <div class="stat-card">
        <div class="num">¥{{ Number(stats.revenue || 0).toFixed(2) }}</div>
        <div class="label">总营收</div>
      </div>
    </div>

    <div v-if="stats.pendingShop > 0" class="pending-tip" @click="$router.push('/a/shops')">
      <van-icon name="warning-o" /> 有 {{ stats.pendingShop }} 家店铺待审核，点击处理
    </div>

    <div class="chart-box">
      <div class="chart-title">近 6 个月营收与订单趋势</div>
      <Chart :option="trendOption" />
    </div>

    <div class="chart-box">
      <div class="chart-title">订单状态分布</div>
      <Chart :option="statusOption" />
    </div>

    <div class="chart-box">
      <div class="chart-title">店铺分类分布</div>
      <Chart :option="catOption" />
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import Chart from '../../components/Chart.vue'
import { statsApi } from '../../api'

export default {
  name: 'AdminDashboard',
  components: { Chart },
  setup() {
    const stats = ref({})

    const trendOption = computed(() => ({
      tooltip: { trigger: 'axis' },
      legend: { data: ['营收', '订单数'], bottom: 0 },
      grid: { left: 45, right: 40, top: 20, bottom: 40 },
      xAxis: { type: 'category', data: stats.value.months || [] },
      yAxis: [
        { type: 'value', name: '营收' },
        { type: 'value', name: '订单' }
      ],
      series: [
        {
          name: '营收',
          type: 'line',
          smooth: true,
          areaStyle: { color: 'rgba(255,107,53,.15)' },
          itemStyle: { color: '#ff6b35' },
          data: (stats.value.revenueTrend || []).map((v) => Number(v))
        },
        {
          name: '订单数',
          type: 'bar',
          yAxisIndex: 1,
          itemStyle: { color: '#42b983' },
          data: stats.value.orderTrend || []
        }
      ]
    }))

    const statusOption = computed(() => ({
      tooltip: { trigger: 'item' },
      legend: { bottom: 0, type: 'scroll' },
      series: [
        {
          name: '订单状态',
          type: 'pie',
          radius: ['35%', '62%'],
          center: ['50%', '42%'],
          data: stats.value.statusDist || [],
          label: { formatter: '{b}\n{c}' }
        }
      ]
    }))

    const catOption = computed(() => ({
      tooltip: { trigger: 'axis' },
      grid: { left: 40, right: 16, top: 20, bottom: 50 },
      xAxis: { type: 'category', data: stats.value.catNames || [], axisLabel: { interval: 0, rotate: 30 } },
      yAxis: { type: 'value' },
      series: [
        {
          name: '店铺数',
          type: 'bar',
          itemStyle: { color: '#ff6b35', borderRadius: [4, 4, 0, 0] },
          data: stats.value.catValues || []
        }
      ]
    }))

    onMounted(async () => {
      const { data } = await statsApi.admin()
      stats.value = data
    })

    return { stats, trendOption, statusOption, catOption }
  }
}
</script>

<style scoped>
.pending-tip {
  margin: 0 12px 8px;
  background: #fff7f2;
  color: #ff6b35;
  padding: 10px 14px;
  border-radius: 8px;
  font-size: 13px;
}
</style>
