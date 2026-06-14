<template>
  <div class="page">
    <van-nav-bar title="我的订单" />

    <van-tabs v-model:active="active" sticky color="#ff6b35" title-active-color="#ff6b35" @change="onTab">
      <van-tab v-for="t in tabs" :key="t.value" :title="t.label" />
    </van-tabs>

    <van-list
      v-model:loading="loading"
      :finished="finished"
      finished-text="没有更多了"
      @load="loadMore"
    >
      <div v-for="o in orders" :key="o.order.id" class="order-card" @click="$router.push('/order/' + o.order.id)">
        <div class="oc-head">
          <span class="oc-shop">{{ o.shopName }}</span>
          <span class="oc-status">{{ statusText(o.order.status) }}</span>
        </div>
        <div class="oc-items">
          <van-image
            v-for="it in o.items.slice(0, 4)"
            :key="it.id"
            width="50"
            height="50"
            radius="6"
            :src="imgUrl(it.dishImage)"
            fit="cover"
          />
          <div class="oc-total">
            <div>共 {{ totalQty(o.items) }} 件</div>
            <div class="price">{{ Number(o.order.totalAmount).toFixed(2) }}</div>
          </div>
        </div>
        <div class="oc-actions" @click.stop>
          <van-button v-if="o.order.status === 1" size="small" round type="primary" color="#ff6b35" @click="pay(o)">去支付</van-button>
          <van-button v-if="o.order.status === 1" size="small" round plain @click="cancel(o)">取消</van-button>
          <van-button v-if="o.order.status === 4" size="small" round type="primary" color="#ff6b35" @click="confirm(o)">确认收货</van-button>
          <van-button v-if="o.order.status === 5 && !o.reviewed" size="small" round plain @click="review(o)">评价</van-button>
        </div>
      </div>
      <van-empty v-if="!loading && orders.length === 0" description="暂无订单" />
    </van-list>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { showConfirmDialog, showSuccessToast } from 'vant'
import { orderApi } from '../../api'
import { imgUrl } from '../../utils/request'
import { ORDER_STATUS } from '../../utils/const'

export default {
  name: 'UserOrders',
  setup() {
    const router = useRouter()
    const tabs = [
      { label: '全部', value: null },
      { label: '待支付', value: 1 },
      { label: '进行中', value: 3 },
      { label: '已完成', value: 5 },
      { label: '已取消', value: 6 }
    ]
    const active = ref(0)
    const orders = ref([])
    const page = ref(0)
    const loading = ref(false)
    const finished = ref(false)

    const statusText = (s) => ORDER_STATUS[s] || ''
    const totalQty = (items) => items.reduce((sum, i) => sum + i.quantity, 0)

    const loadMore = async () => {
      page.value += 1
      try {
        const { data } = await orderApi.userPage({
          page: page.value,
          size: 10,
          status: tabs[active.value].value || undefined
        })
        orders.value.push(...data.records)
        if (orders.value.length >= data.total || data.records.length === 0) {
          finished.value = true
        }
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
    const onTab = () => reset()

    const pay = async (o) => {
      await orderApi.pay(o.order.id)
      showSuccessToast('支付成功')
      reset()
    }
    const cancel = (o) => {
      showConfirmDialog({ title: '提示', message: '确定取消该订单吗？' })
        .then(async () => {
          await orderApi.cancel(o.order.id)
          showSuccessToast('已取消')
          reset()
        })
        .catch(() => {})
    }
    const confirm = (o) => {
      showConfirmDialog({ title: '提示', message: '确认已收到商品？' })
        .then(async () => {
          await orderApi.confirm(o.order.id)
          showSuccessToast('已确认收货')
          reset()
        })
        .catch(() => {})
    }
    const review = (o) => router.push('/review/' + o.order.id)

    return {
      tabs, active, orders, loading, finished,
      imgUrl, statusText, totalQty, loadMore, onTab, pay, cancel, confirm, review
    }
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
  font-size: 14px;
  font-weight: bold;
  margin-bottom: 10px;
}
.oc-status {
  color: #ff6b35;
  font-weight: normal;
}
.oc-items {
  display: flex;
  align-items: center;
  gap: 8px;
}
.oc-total {
  margin-left: auto;
  text-align: right;
  font-size: 12px;
  color: #969799;
}
.oc-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 10px;
}
</style>
