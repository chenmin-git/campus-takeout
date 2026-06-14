<template>
  <div class="page">
    <van-nav-bar title="确认订单" left-arrow @click-left="$router.back()" />

    <!-- 地址 -->
    <van-cell-group inset style="margin-top: 12px">
      <van-cell
        v-if="address"
        :title="address.name + '  ' + address.phone"
        :label="address.detail"
        icon="location-o"
        is-link
        @click="goAddress"
      />
      <van-cell
        v-else
        title="请选择收货地址"
        icon="location-o"
        is-link
        @click="goAddress"
      />
    </van-cell-group>

    <!-- 商品清单 -->
    <van-cell-group inset style="margin-top: 12px">
      <van-cell :title="shopName" title-class="shop-title" />
      <div v-for="i in cart.items" :key="i.dishId" class="goods-row">
        <van-image width="44" height="44" radius="6" :src="imgUrl(i.image)" fit="cover" />
        <span class="g-name">{{ i.name }}</span>
        <span class="g-qty">x{{ i.quantity }}</span>
        <span class="price">{{ (i.price * i.quantity).toFixed(2) }}</span>
      </div>
    </van-cell-group>

    <!-- 费用 -->
    <van-cell-group inset style="margin-top: 12px">
      <van-cell title="商品金额" :value="'¥' + cart.totalPrice" />
      <van-cell title="包装费" :value="'¥' + packFee.toFixed(2)" />
      <van-cell title="配送费" :value="'¥' + deliveryFee.toFixed(2)" />
      <van-field v-model="remark" label="备注" placeholder="口味、偏好等" />
    </van-cell-group>

    <van-submit-bar
      :price="totalCent"
      button-text="提交订单"
      button-color="#ff6b35"
      :loading="submitting"
      @submit="onSubmit"
    />
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showToast, showSuccessToast } from 'vant'
import { addressApi, shopApi, orderApi } from '../../api'
import { imgUrl } from '../../utils/request'
import { useCartStore } from '../../store/cart'

export default {
  name: 'OrderConfirm',
  setup() {
    const route = useRoute()
    const router = useRouter()
    const cart = useCartStore()

    const address = ref(null)
    const shopName = ref('')
    const packFee = ref(0)
    const deliveryFee = ref(0)
    const remark = ref('')
    const submitting = ref(false)

    const totalCent = computed(() =>
      Math.round((Number(cart.totalPrice) + packFee.value + deliveryFee.value) * 100)
    )

    const goAddress = () => router.push({ path: '/address', query: { select: 1 } })

    const loadAddress = async () => {
      const { data } = await addressApi.list()
      // 选择页返回时带回选中地址
      const selectedId = route.query.addressId
      if (selectedId) {
        address.value = data.find((a) => a.id === Number(selectedId)) || data[0] || null
      } else {
        address.value = data.find((a) => a.isDefault === 1) || data[0] || null
      }
    }

    const onSubmit = async () => {
      if (!address.value) {
        showToast('请先选择收货地址')
        return
      }
      if (cart.items.length === 0) {
        showToast('购物车为空')
        return
      }
      submitting.value = true
      try {
        const { data: orderId } = await orderApi.create({
          shopId: cart.shopId,
          addressId: address.value.id,
          remark: remark.value,
          items: cart.items.map((i) => ({ dishId: i.dishId, quantity: i.quantity }))
        })
        cart.clear()
        showSuccessToast('下单成功')
        router.replace('/order/' + orderId)
      } catch (e) {
        // 拦截器提示
      } finally {
        submitting.value = false
      }
    }

    onMounted(async () => {
      if (!cart.shopId || cart.items.length === 0) {
        showToast('购物车为空')
        router.back()
        return
      }
      const { data } = await shopApi.detail(cart.shopId)
      shopName.value = data.shop.name
      deliveryFee.value = Number(data.shop.deliveryFee)
      packFee.value = 1 // 后端固定收取 1 元包装费
      await loadAddress()
    })

    return {
      cart, address, shopName, packFee, deliveryFee, remark, submitting,
      totalCent, imgUrl, goAddress, onSubmit
    }
  }
}
</script>

<style scoped>
.shop-title {
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
</style>
