<template>
  <div class="page">
    <van-nav-bar title="商家工作台" />

    <van-empty v-if="loaded && !stats.hasShop" description="您还没有店铺，请先创建">
      <van-button round type="primary" color="#ff6b35" @click="$router.push('/m/shop')">去创建店铺</van-button>
    </van-empty>

    <template v-if="stats.hasShop">
      <div class="shop-name-bar">{{ stats.shopName }}</div>

      <div class="stat-grid">
        <div class="stat-card">
          <div class="num">¥{{ Number(stats.todayRevenue || 0).toFixed(2) }}</div>
          <div class="label">今日营业额</div>
        </div>
        <div class="stat-card">
          <div class="num">¥{{ Number(stats.monthRevenue || 0).toFixed(2) }}</div>
          <div class="label">本月营业额</div>
        </div>
        <div class="stat-card">
          <div class="num">{{ stats.orderCount || 0 }}</div>
          <div class="label">累计订单</div>
        </div>
        <div class="stat-card">
          <div class="num">{{ stats.pendingOrder || 0 }}</div>
          <div class="label">待接单</div>
        </div>
      </div>

      <div class="chart-box">
        <div class="chart-title">近 6 个月营业额</div>
        <Chart :option="revenueOption" />
      </div>

      <div class="chart-box">
        <div class="chart-title">热销菜品 Top5</div>
        <Chart :option="dishOption" />
      </div>
    </template>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import Chart from '../../components/Chart.vue'
import { statsApi } from '../../api'

export default {
  name: 'MerchantDashboard',
  components: { Chart },
  setup() {
    const stats = ref({})
    const loaded = ref(false)

    const revenueOption = computed(() => ({
      tooltip: { trigger: 'axis' },
      grid: { left: 45, right: 16, top: 20, bottom: 30 },
      xAxis: { type: 'category', data: stats.value.months || [] },
      yAxis: { type: 'value' },
      series: [
        {
          name: '营业额',
          type: 'line',
          smooth: true,
          areaStyle: { color: 'rgba(255,107,53,.15)' },
          itemStyle: { color: '#ff6b35' },
          data: (stats.value.revenueTrend || []).map((v) => Number(v))
        }
      ]
    }))

    const dishOption = computed(() => ({
      tooltip: { trigger: 'item' },
      legend: { bottom: 0, type: 'scroll' },
      series: [
        {
          name: '销量',
          type: 'pie',
          radius: ['35%', '62%'],
          center: ['50%', '42%'],
          data: stats.value.topDishes || [],
          label: { formatter: '{b}\n{c}' }
        }
      ]
    }))

    onMounted(async () => {
      const { data } = await statsApi.merchant()
      stats.value = data
      loaded.value = true
    })

    return { stats, loaded, revenueOption, dishOption }
  }
}
</script>

<style scoped>
.shop-name-bar {
  background: #fff;
  padding: 14px 16px;
  font-size: 16px;
  font-weight: bold;
  border-left: 3px solid #ff6b35;
  margin: 12px;
  border-radius: 8px;
}
</style>
