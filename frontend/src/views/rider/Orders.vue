<template>
  <div class="page">
    <van-nav-bar title="我的配送" />

    <van-tabs v-model:active="active" sticky color="#ff6b35" title-active-color="#ff6b35" @change="reset">
      <van-tab v-for="t in tabs" :key="t.label" :title="t.label" />
    </van-tabs>

    <van-list v-model:loading="loading" :finished="finished" finished-text="没有更多了" @load="loadMore">
      <div v-for="o in orders" :key="o.order.id" class="order-card">
        <div class="oc-head">
          <span class="oc-shop">{{ o.shopName }}</span>
          <span class="oc-status">{{ statusText(o.order.status) }}</span>
        </div>
        <div class="oc-addr"><van-icon name="location-o" /> {{ addrText(o.order.addressSnapshot) }}</div>
        <!-- 配送中：展示剩余配送时效 -->
        <div v-if="o.order.status === 4 && o.order.slaDeadline" class="oc-sla" :class="{ overtime: slaText(o.order.slaDeadline).overtime }">
          <van-icon name="clock-o" /> {{ slaText(o.order.slaDeadline).text }}
          <span v-if="o.order.extendStatus === 1" class="sla-pending">（延期待审批）</span>
        </div>
        <div class="oc-foot">
          <span class="price">配送费 ¥{{ Number(o.order.deliveryFee).toFixed(2) }}</span>
          <div class="oc-btns">
            <van-button size="small" round plain @click="$router.push('/r/order/' + o.order.id)">配送导航</van-button>
            <van-button v-if="o.order.status === 4" size="small" round type="primary" color="#ff6b35" @click="deliver(o)">确认送达</van-button>
          </div>
        </div>
      </div>
      <van-empty v-if="!loading && orders.length === 0" description="暂无配送订单" />
    </van-list>
  </div>
</template>

<script>
import { ref } from 'vue'
import { showSuccessToast } from 'vant'
import { orderApi } from '../../api'
import { ORDER_STATUS, slaText } from '../../utils/const'

export default {
  name: 'RiderOrders',
  setup() {
    const tabs = [
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
        const { data } = await orderApi.riderPage({
          page: page.value,
          size: 10,
          status: tabs[active.value].value
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

    const deliver = async (o) => {
      await orderApi.riderDeliver(o.order.id)
      showSuccessToast('已送达')
      reset()
    }

    return { tabs, active, orders, loading, finished, statusText, addrText, slaText, loadMore, reset, deliver }
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
  align-items: center;
}
.oc-shop {
  font-size: 15px;
  font-weight: bold;
}
.oc-status {
  color: #ff6b35;
  font-weight: bold;
  font-size: 13px;
}
.oc-addr {
  font-size: 13px;
  color: #646566;
  margin: 8px 0;
}
.oc-sla {
  font-size: 13px;
  color: #1989fa;
  margin: 6px 0;
}
.oc-sla.overtime {
  color: #ee0a24;
}
.sla-pending {
  color: #ff976a;
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
