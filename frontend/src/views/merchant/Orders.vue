<template>
  <div class="page">
    <van-nav-bar title="订单管理" />

    <van-tabs v-model:active="active" sticky color="#ff6b35" title-active-color="#ff6b35" @change="reset">
      <van-tab v-for="t in tabs" :key="t.label" :title="t.label" />
    </van-tabs>

    <van-list v-model:loading="loading" :finished="finished" finished-text="没有更多了" @load="loadMore">
      <div v-for="o in orders" :key="o.order.id" class="order-card">
        <div class="oc-head">
          <span class="oc-no">#{{ o.order.orderNo }}</span>
          <span class="oc-status">{{ statusText(o.order.status) }}</span>
        </div>
        <div class="oc-addr">{{ addrText(o.order.addressSnapshot) }}</div>
        <div class="oc-items">
          <span v-for="it in o.items" :key="it.id" class="oc-it">{{ it.dishName }}×{{ it.quantity }}</span>
        </div>
        <div class="oc-foot">
          <span class="price">{{ Number(o.order.totalAmount).toFixed(2) }}</span>
          <div class="oc-btns">
            <van-button v-if="o.order.status === 2" size="small" round type="primary" color="#ff6b35" @click="advance(o, 3)">接单</van-button>
            <van-button v-if="o.order.status === 3" size="small" round type="primary" color="#ff6b35" @click="advance(o, 4)">开始配送</van-button>
            <van-button v-if="o.order.status === 4" size="small" round type="primary" color="#ff6b35" @click="advance(o, 5)">完成订单</van-button>
            <van-button size="small" round plain @click="$router.push('/order/' + o.order.id)">详情</van-button>
          </div>
        </div>
      </div>
      <van-empty v-if="!loading && orders.length === 0" description="暂无订单" />
    </van-list>
  </div>
</template>

<script>
import { ref } from 'vue'
import { showSuccessToast } from 'vant'
import { orderApi } from '../../api'
import { ORDER_STATUS } from '../../utils/const'

export default {
  name: 'MerchantOrders',
  setup() {
    const tabs = [
      { label: '全部', value: null },
      { label: '待接单', value: 2 },
      { label: '待配送', value: 3 },
      { label: '配送中', value: 4 },
      { label: '已完成', value: 5 }
    ]
    const active = ref(0)
    const orders = ref([])
    const page = ref(0)
    const loading = ref(false)
    const finished = ref(false)

    const statusText = (s) => ORDER_STATUS[s] || ''
    const addrText = (snap) => {
      try {
        const a = JSON.parse(snap)
        return `${a.name} ${a.phone} ${a.detail}`
      } catch (e) {
        return snap || ''
      }
    }

    const loadMore = async () => {
      page.value += 1
      try {
        const { data } = await orderApi.merchantPage({
          page: page.value,
          size: 10,
          status: tabs[active.value].value || undefined
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

    const advance = async (o, status) => {
      await orderApi.advance(o.order.id, status)
      showSuccessToast('操作成功')
      reset()
    }

    return { tabs, active, orders, loading, finished, statusText, addrText, loadMore, reset, advance }
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
.oc-addr {
  font-size: 13px;
  color: #646566;
  margin: 8px 0;
}
.oc-items {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  font-size: 12px;
  color: #323233;
}
.oc-it {
  background: #f7f8fa;
  padding: 2px 8px;
  border-radius: 4px;
}
.oc-foot {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 12px;
}
.oc-btns {
  display: flex;
  gap: 8px;
}
</style>
