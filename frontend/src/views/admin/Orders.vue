<template>
  <div class="page">
    <van-nav-bar title="订单管理" />

    <div class="filter-bar">
      <van-search
        v-model="filter.keyword"
        placeholder="搜索订单号"
        shape="round"
        style="flex:1;padding:0"
        @search="reset"
        @clear="reset"
      />
    </div>
    <div class="filter-bar" style="padding-top:0">
      <van-dropdown-menu active-color="#ff6b35">
        <van-dropdown-item v-model="filter.status" :options="statusOptions" @change="reset" />
      </van-dropdown-menu>
      <van-button size="small" plain round @click="resetFilter">重置</van-button>
    </div>

    <van-list v-model:loading="loading" :finished="finished" finished-text="没有更多了" @load="loadMore">
      <div v-for="o in orders" :key="o.order.id" class="order-card" @click="$router.push('/order/' + o.order.id)">
        <div class="oc-head">
          <span class="oc-no">#{{ o.order.orderNo }}</span>
          <span class="oc-status">{{ statusText(o.order.status) }}</span>
        </div>
        <div class="oc-shop">{{ o.shopName }}</div>
        <div class="oc-foot">
          <span class="oc-time">{{ fmt(o.order.createTime) }}</span>
          <span class="price">{{ Number(o.order.totalAmount).toFixed(2) }}</span>
        </div>
      </div>
      <van-empty v-if="!loading && orders.length === 0" description="暂无订单" />
    </van-list>
  </div>
</template>

<script>
import { ref, reactive } from 'vue'
import { orderApi } from '../../api'
import { ORDER_STATUS } from '../../utils/const'

export default {
  name: 'AdminOrders',
  setup() {
    const orders = ref([])
    const page = ref(0)
    const loading = ref(false)
    const finished = ref(false)
    const filter = reactive({ keyword: '', status: -1 })
    const statusOptions = [
      { text: '全部状态', value: -1 },
      { text: '待支付', value: 1 },
      { text: '待接单', value: 2 },
      { text: '待配送', value: 3 },
      { text: '配送中', value: 4 },
      { text: '已完成', value: 5 },
      { text: '已取消', value: 6 }
    ]

    const statusText = (s) => ORDER_STATUS[s] || ''
    const fmt = (t) => (t ? t.replace('T', ' ').slice(0, 16) : '')

    const loadMore = async () => {
      page.value += 1
      try {
        const { data } = await orderApi.adminPage({
          page: page.value,
          size: 10,
          keyword: filter.keyword || undefined,
          status: filter.status === -1 ? undefined : filter.status
        })
        orders.value.push(...data.records)
        if (orders.value.length >= data.total || data.records.length === 0) finished.value = true
      } catch (e) {
        finished.value = true
      } finally {
        loading.value = false
      }
    }

    const reset = () => {
      orders.value = []
      page.value = 0
      finished.value = false
      loading.value = true
      loadMore()
    }
    const resetFilter = () => {
      filter.keyword = ''
      filter.status = -1
      reset()
    }

    return { orders, loading, finished, filter, statusOptions, statusText, fmt, loadMore, reset, resetFilter }
  }
}
</script>

<style scoped>
.order-card {
  background: #fff;
  margin: 8px 12px;
  border-radius: 10px;
  padding: 12px;
}
.oc-head {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
}
.oc-no {
  color: #969799;
}
.oc-status {
  color: #ff6b35;
  font-weight: bold;
}
.oc-shop {
  font-size: 15px;
  font-weight: bold;
  margin: 8px 0;
}
.oc-foot {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.oc-time {
  font-size: 12px;
  color: #969799;
}
</style>
