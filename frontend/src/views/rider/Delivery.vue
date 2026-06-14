<template>
  <div class="page" v-if="vo">
    <van-nav-bar title="配送导航" left-arrow @click-left="$router.back()" />

    <!-- 高德地图：展示商家到收货地址的配送路线 -->
    <div class="map-card">
      <AMapView :seed="order.id" :shop-name="vo.shopName" dest-name="收货地址" />
    </div>

    <van-cell-group inset style="margin-top: 12px">
      <van-cell title="取餐商家" :value="vo.shopName" />
      <van-cell title="收货地址" :label="addrText(order.addressSnapshot)" icon="location-o" />
      <van-cell title="配送费" :value="'¥' + Number(order.deliveryFee).toFixed(2)" />
      <van-cell title="订单状态" :value="statusText(order.status)" />
      <!-- 配送时效：配送中(4) 显示实时倒计时 -->
      <van-cell v-if="order.status === 4 && order.slaDeadline" title="配送时效">
        <template #value>
          <span :class="{ overtime: sla.overtime }">{{ sla.text }}</span>
          <span v-if="order.extendStatus === 2" class="extend-tag">已延期</span>
        </template>
      </van-cell>
      <van-cell v-if="order.extendStatus === 1" title="延期申请" value="待用户审批" value-class="pending-tag" />
      <van-cell v-else-if="order.extendStatus === 3" title="延期申请" value="用户已拒绝" value-class="overtime" />
    </van-cell-group>

    <van-cell-group inset style="margin-top: 12px">
      <van-cell title="订单编号" :value="order.orderNo" />
      <van-cell title="备注" :value="order.remark || '无'" />
    </van-cell-group>

    <div class="bottom-actions">
      <van-button v-if="order.status === 4" round block type="primary" color="#ff6b35" @click="deliver">确认送达</van-button>
      <!-- 仅配送中且无待审批申请时允许申请延期 -->
      <van-button v-if="order.status === 4 && order.extendStatus !== 1" round block plain style="margin-top: 10px" @click="openExtend">申请延期</van-button>
      <div v-if="order.status !== 4" class="done-tip">该订单已完成配送</div>
    </div>

    <!-- 申请延期弹窗：填写延长分钟数与原因 -->
    <van-dialog v-model:show="extendShow" title="申请延长配送时效" show-cancel-button
                confirm-button-text="提交" @confirm="submitExtend">
      <van-cell-group inset style="margin: 12px 0">
        <van-field v-model="extendForm.minutes" type="digit" label="延长分钟" placeholder="请输入延长的分钟数" />
        <van-field v-model="extendForm.reason" rows="2" autosize type="textarea" label="原因"
                   placeholder="请填写申请延期的原因" maxlength="100" show-word-limit />
      </van-cell-group>
    </van-dialog>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showConfirmDialog, showSuccessToast, showToast } from 'vant'
import AMapView from '../../components/AMapView.vue'
import { orderApi } from '../../api'
import { ORDER_STATUS, slaText } from '../../utils/const'

export default {
  name: 'RiderDelivery',
  components: { AMapView },
  setup() {
    const route = useRoute()
    const router = useRouter()
    const id = Number(route.params.id)
    const vo = ref(null)
    const order = computed(() => vo.value.order)

    const statusText = (s) => ORDER_STATUS[s] || ''
    const addrText = (snap) => {
      try {
        const a = JSON.parse(snap)
        return `${a.name} ${a.phone} ${a.detail}`
      } catch (e) {
        return snap || ''
      }
    }

    // 实时倒计时：每 30s 刷新 now 触发 sla 文案重算，离开页面清理定时器
    const now = ref(Date.now())
    let timer = null
    const sla = computed(() => {
      now.value
      return slaText(order.value.slaDeadline)
    })

    const load = async () => {
      const { data } = await orderApi.detail(id)
      vo.value = data
    }

    const deliver = () => {
      showConfirmDialog({ title: '提示', message: '确认已送达该订单？' })
        .then(async () => {
          await orderApi.riderDeliver(id)
          showSuccessToast('已送达')
          router.back()
        })
        .catch(() => {})
    }

    // 申请延期：填写延长分钟数与原因，提交后等待用户审批
    const extendShow = ref(false)
    const extendForm = reactive({ minutes: '', reason: '' })
    const openExtend = () => {
      extendForm.minutes = ''
      extendForm.reason = ''
      extendShow.value = true
    }
    const submitExtend = async () => {
      const minutes = parseInt(extendForm.minutes, 10)
      if (!minutes || minutes <= 0) {
        showToast('请输入大于 0 的分钟数')
        return
      }
      await orderApi.riderRequestExtend(id, { minutes, reason: extendForm.reason })
      showSuccessToast('已提交，等待用户审批')
      extendShow.value = false
      load()
    }

    onMounted(() => {
      load()
      timer = setInterval(() => { now.value = Date.now() }, 30000)
    })
    onUnmounted(() => { if (timer) clearInterval(timer) })

    return { vo, order, statusText, addrText, sla, deliver, extendShow, extendForm, openExtend, submitExtend }
  }
}
</script>

<style scoped>
.map-card {
  margin: 12px;
}
.bottom-actions {
  padding: 20px 16px;
}
.done-tip {
  text-align: center;
  color: #969799;
  font-size: 13px;
}
.overtime {
  color: #ee0a24;
}
.pending-tag {
  color: #ff976a;
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
