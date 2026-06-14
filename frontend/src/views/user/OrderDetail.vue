<template>
  <div class="page" v-if="vo">
    <van-nav-bar title="订单详情" left-arrow @click-left="$router.back()" />

    <!-- 状态条 -->
    <div class="status-banner">
      <div class="sb-text">{{ statusText(order.status) }}</div>
      <van-steps :active="stepActive" active-color="#fff" inactive-color="rgba(255,255,255,.5)">
        <van-step>下单</van-step>
        <van-step>支付</van-step>
        <van-step>接单</van-step>
        <van-step>配送</van-step>
        <van-step>完成</van-step>
      </van-steps>
    </div>

    <!-- 骑手延期申请：待用户审批时展示卡片 + 同意/拒绝 -->
    <div v-if="order.extendStatus === 1" class="extend-card">
      <div class="ec-title">骑手申请延长配送时效</div>
      <div class="ec-row">延长时间：{{ order.extendMinutes }} 分钟</div>
      <div class="ec-row">申请原因：{{ order.extendReason || '无' }}</div>
      <div class="ec-btns">
        <van-button size="small" round type="primary" color="#ff6b35" @click="decide(1)">同意</van-button>
        <van-button size="small" round plain @click="decide(0)">拒绝</van-button>
      </div>
    </div>

    <!-- 配送中：高德地图展示骑手配送路线 -->
    <div v-if="order.status === 4" class="map-card">
      <AMapView :seed="order.id" :shop-name="vo.shopName" dest-name="我的地址" />
    </div>

    <!-- 地址 -->
    <van-cell-group inset style="margin-top: 12px">
      <van-cell :title="addr.name + '  ' + addr.phone" :label="addr.detail" icon="location-o" />
    </van-cell-group>

    <!-- 商品 -->
    <van-cell-group inset style="margin-top: 12px">
      <van-cell :title="vo.shopName" title-class="bold" />
      <div v-for="it in vo.items" :key="it.id" class="goods-row">
        <van-image width="44" height="44" radius="6" :src="imgUrl(it.dishImage)" fit="cover" />
        <span class="g-name">{{ it.dishName }}</span>
        <span class="g-qty">x{{ it.quantity }}</span>
        <span class="price">{{ (it.price * it.quantity).toFixed(2) }}</span>
      </div>
    </van-cell-group>

    <!-- 费用 -->
    <van-cell-group inset style="margin-top: 12px">
      <van-cell title="商品金额" :value="'¥' + Number(order.goodsAmount).toFixed(2)" />
      <van-cell title="包装费" :value="'¥' + Number(order.packFee).toFixed(2)" />
      <van-cell title="配送费" :value="'¥' + Number(order.deliveryFee).toFixed(2)" />
      <van-cell title="实付金额" :value="'¥' + Number(order.totalAmount).toFixed(2)" value-class="price-bold" />
    </van-cell-group>

    <!-- 订单信息 -->
    <van-cell-group inset style="margin-top: 12px">
      <!-- 配送时效：接单后(3/4)显示实时倒计时；已完成(5)显示是否准时 -->
      <van-cell v-if="[3, 4].includes(order.status) && order.slaDeadline" title="配送时效">
        <template #value>
          <span :class="{ overtime: sla.overtime }">{{ sla.text }}</span>
          <span v-if="order.extendStatus === 2" class="extend-tag">已延期</span>
        </template>
      </van-cell>
      <van-cell v-else-if="order.status === 5 && order.slaDeadline" title="配送时效" :value="finishOnTimeText" />
      <van-cell title="订单编号" :value="order.orderNo" />
      <van-cell title="下单时间" :value="fmt(order.createTime)" />
      <van-cell title="备注" :value="order.remark || '无'" />
    </van-cell-group>

    <div class="bottom-actions">
      <van-button v-if="order.status === 1" round type="primary" color="#ff6b35" @click="pay">去支付</van-button>
      <van-button v-if="order.status === 1" round plain @click="cancel">取消订单</van-button>
      <van-button v-if="order.status === 4" round type="primary" color="#ff6b35" @click="confirm">确认收货</van-button>
      <van-button v-if="[2, 3, 4].includes(order.status)" round plain @click="refund">申请退款</van-button>
      <van-button v-if="order.status === 5 && !vo.reviewed" round plain @click="$router.push('/review/' + order.id)">去评价</van-button>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showConfirmDialog, showSuccessToast } from 'vant'
import AMapView from '../../components/AMapView.vue'
import { orderApi } from '../../api'
import { imgUrl } from '../../utils/request'
import { ORDER_STATUS, slaText } from '../../utils/const'

export default {
  name: 'OrderDetail',
  components: { AMapView },
  setup() {
    const route = useRoute()
    const router = useRouter()
    const id = Number(route.params.id)
    const vo = ref(null)
    const order = computed(() => vo.value.order)
    const addr = computed(() => {
      try {
        return JSON.parse(order.value.addressSnapshot)
      } catch (e) {
        return { name: '', phone: '', detail: order.value.addressSnapshot || '' }
      }
    })

    const statusText = (s) => ORDER_STATUS[s] || ''
    const stepActive = computed(() => {
      const map = { 1: 0, 2: 2, 3: 2, 4: 3, 5: 4, 6: 0 }
      return map[order.value.status] ?? 0
    })
    const fmt = (t) => (t ? t.replace('T', ' ').slice(0, 16) : '')

    // 实时倒计时：每 30s 刷新 now 触发 sla 文案重算，离开页面清理定时器
    const now = ref(Date.now())
    let timer = null
    const sla = computed(() => {
      now.value
      return slaText(order.value.slaDeadline)
    })
    // 已完成订单：比较送达时间与截止时间判断是否准时
    const finishOnTimeText = computed(() => {
      const o = order.value
      if (!o.finishTime || !o.slaDeadline) return '已完成'
      const finish = new Date(String(o.finishTime).replace(' ', 'T')).getTime()
      const ddl = new Date(String(o.slaDeadline).replace(' ', 'T')).getTime()
      if (isNaN(finish) || isNaN(ddl)) return '已完成'
      return finish <= ddl ? '已准时送达' : '已超时送达'
    })

    const load = async () => {
      const { data } = await orderApi.detail(id)
      vo.value = data
    }
    const pay = async () => {
      await orderApi.pay(id)
      showSuccessToast('支付成功')
      load()
    }
    const cancel = () => {
      showConfirmDialog({ title: '提示', message: '确定取消该订单吗？' })
        .then(async () => {
          await orderApi.cancel(id)
          showSuccessToast('已取消')
          load()
        })
        .catch(() => {})
    }
    const confirm = () => {
      showConfirmDialog({ title: '提示', message: '确认已收到商品？' })
        .then(async () => {
          await orderApi.confirm(id)
          showSuccessToast('已确认收货')
          load()
        })
        .catch(() => {})
    }
    // 退款：已支付未完成订单（待接单/待配送/配送中）可申请退款
    const refund = () => {
      showConfirmDialog({ title: '提示', message: '确定申请退款吗？' })
        .then(async () => {
          await orderApi.refund(id)
          showSuccessToast('退款成功')
          load()
        })
        .catch(() => {})
    }
    // 审批骑手延期申请：approve=1 同意（时效顺延）/ 0 拒绝
    const decide = (approve) => {
      showConfirmDialog({ title: '提示', message: approve ? '同意延长配送时效？' : '拒绝该延期申请？' })
        .then(async () => {
          await orderApi.decideExtend(id, approve)
          showSuccessToast(approve ? '已同意' : '已拒绝')
          load()
        })
        .catch(() => {})
    }

    onMounted(() => {
      load()
      timer = setInterval(() => { now.value = Date.now() }, 30000)
    })
    onUnmounted(() => { if (timer) clearInterval(timer) })

    return { vo, order, addr, statusText, stepActive, fmt, imgUrl, sla, finishOnTimeText, pay, cancel, confirm, refund, decide }
  }
}
</script>

<style scoped>
.map-card {
  margin: 12px;
}
.status-banner {
  background: linear-gradient(135deg, #ff8c42, #ff6b35);
  color: #fff;
  padding: 20px 16px 12px;
}
.sb-text {
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 16px;
}
.status-banner :deep(.van-steps) {
  background: transparent;
}
.status-banner :deep(.van-step__title) {
  color: rgba(255, 255, 255, 0.85);
}
.bold {
  font-weight: bold;
}
.goods-row {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 16px;
}
.g-name {
  flex: 1;
}
.g-qty {
  color: #969799;
  font-size: 13px;
}
.price-bold {
  color: #ff4d3a;
  font-weight: bold;
}
.bottom-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  padding: 20px 16px;
}
.extend-card {
  margin: 12px;
  padding: 14px 16px;
  background: #fff7e6;
  border: 1px solid #ffd591;
  border-radius: 8px;
}
.ec-title {
  font-weight: bold;
  color: #d46b08;
  margin-bottom: 8px;
}
.ec-row {
  font-size: 13px;
  color: #614700;
  margin-bottom: 6px;
}
.ec-btns {
  display: flex;
  gap: 10px;
  margin-top: 10px;
}
.overtime {
  color: #ee0a24;
}
.extend-tag {
  margin-left: 6px;
  padding: 0 6px;
  font-size: 11px;
  color: #fff;
  background: #07c160;
  border-radius: 3px;
}
</style>
