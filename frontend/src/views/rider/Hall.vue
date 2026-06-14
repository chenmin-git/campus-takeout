<template>
  <div class="page">
    <van-nav-bar title="抢单大厅">
      <template #right>
        <van-icon name="replay" @click="reset" />
      </template>
    </van-nav-bar>

    <van-list v-model:loading="loading" :finished="finished" finished-text="没有更多了" @load="loadMore">
      <div v-for="o in orders" :key="o.order.id" class="order-card">
        <div class="oc-head">
          <span class="oc-shop">{{ o.shopName }}</span>
          <span class="oc-fee">配送费 ¥{{ Number(o.order.deliveryFee).toFixed(2) }}</span>
        </div>
        <div class="oc-addr"><van-icon name="location-o" /> {{ addrText(o.order.addressSnapshot) }}</div>
        <div class="oc-items">
          <span v-for="it in o.items" :key="it.id" class="oc-it">{{ it.dishName }}×{{ it.quantity }}</span>
        </div>
        <div class="oc-foot">
          <span class="oc-time">{{ fmt(o.order.createTime) }}</span>
          <van-button size="small" round type="primary" color="#ff6b35" @click="grab(o)">抢单</van-button>
        </div>
      </div>
      <van-empty v-if="!loading && orders.length === 0" description="暂无可抢订单" />
    </van-list>
  </div>
</template>

<script>
import { ref } from 'vue'
import { showSuccessToast, showToast } from 'vant'
import { orderApi } from '../../api'

export default {
  name: 'RiderHall',
  setup() {
    const orders = ref([])
    const page = ref(0)
    const loading = ref(false)
    const finished = ref(false)

    const addrText = (snap) => {
      try {
        const a = JSON.parse(snap)
        return `${a.name} ${a.phone} ${a.detail}`
      } catch (e) {
        return snap || ''
      }
    }
    const fmt = (t) => (t ? t.replace('T', ' ').slice(0, 16) : '')

    const loadMore = async () => {
      page.value += 1
      try {
        const { data } = await orderApi.riderAvailable({ page: page.value, size: 10 })
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

    // 抢单：成功后从列表移除；若被其他骑手抢走，提示并刷新
    const grab = async (o) => {
      try {
        await orderApi.riderGrab(o.order.id)
        showSuccessToast('抢单成功')
        reset()
      } catch (e) {
        showToast('手慢了，该单已被抢')
        reset()
      }
    }

    return { orders, loading, finished, addrText, fmt, loadMore, reset, grab }
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
.oc-fee {
  color: #ff6b35;
  font-size: 13px;
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
.oc-time {
  font-size: 12px;
  color: #969799;
}
</style>
