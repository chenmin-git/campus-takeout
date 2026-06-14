<template>
  <div class="page shop-detail">
    <van-nav-bar :title="shop?.name || '店铺'" left-arrow @click-left="$router.back()" />

    <div v-if="shop" class="shop-header">
      <van-image width="64" height="64" radius="8" :src="imgUrl(shop.logo)" fit="cover" />
      <div class="hd-info">
        <div class="hd-name">{{ shop.name }}</div>
        <div class="hd-meta">
          <van-rate :model-value="Number(shop.rating)" readonly size="12" color="#ffb400" allow-half />
          <span>{{ Number(shop.rating).toFixed(1) }} · 月售 {{ shop.sales }}</span>
        </div>
        <div class="hd-notice" v-if="shop.notice">公告：{{ shop.notice }}</div>
      </div>
    </div>

    <van-tabs v-model:active="tab" sticky color="#ff6b35" title-active-color="#ff6b35">
      <van-tab title="点餐">
        <div class="dish-list">
          <div v-for="d in dishes" :key="d.id" class="dish-item">
            <van-image width="76" height="76" radius="8" :src="imgUrl(d.image)" fit="cover" />
            <div class="dish-info">
              <div class="dish-name">{{ d.name }}</div>
              <div class="dish-desc">{{ d.description }}</div>
              <div class="dish-sales">月售 {{ d.sales }}</div>
              <div class="dish-bottom">
                <span class="price">{{ Number(d.price).toFixed(2) }}</span>
                <div class="stepper">
                  <van-icon
                    v-if="getQuantity(d.id) > 0"
                    name="minus"
                    class="step-btn"
                    @click="cart.minus(d.id)"
                  />
                  <span v-if="getQuantity(d.id) > 0" class="step-num">{{ getQuantity(d.id) }}</span>
                  <van-icon name="plus" class="step-btn add" @click="addDish(d)" />
                </div>
              </div>
            </div>
          </div>
          <van-empty v-if="dishes.length === 0" description="暂无菜品" />
        </div>
      </van-tab>

      <van-tab title="评价">
        <div class="review-list">
          <div v-for="r in reviews" :key="r.review.id" class="review-item">
            <div class="rv-head">
              <van-image round width="32" height="32" :src="imgUrl(r.avatar)" />
              <span class="rv-name">{{ r.nickname }}</span>
              <van-rate :model-value="r.review.rating" readonly size="12" color="#ffb400" />
            </div>
            <div class="rv-content">{{ r.review.content }}</div>
            <div v-if="r.review.reply" class="rv-reply">商家回复：{{ r.review.reply }}</div>
          </div>
          <van-empty v-if="reviews.length === 0" description="暂无评价" />
        </div>
      </van-tab>
    </van-tabs>

    <!-- 购物车浮层 -->
    <div class="cart-bar" v-if="tab === 0">
      <div class="cart-left" @click="showCart = !showCart">
        <van-badge :content="cart.totalCount || ''">
          <div class="cart-icon" :class="{ empty: cart.totalCount === 0 }"><van-icon name="shopping-cart-o" /></div>
        </van-badge>
        <div class="cart-total">
          <span class="price">{{ cart.totalPrice }}</span>
        </div>
      </div>
      <van-button
        class="cart-submit"
        :class="{ disabled: !canSubmit }"
        round
        color="#ff6b35"
        @click="goConfirm"
      >
        {{ submitText }}
      </van-button>
    </div>

    <!-- 已选清单 -->
    <van-popup v-model:show="showCart" position="bottom" round>
      <div class="cart-popup">
        <div class="cp-head">
          <span>已选商品</span>
          <span class="cp-clear" @click="cart.clear()">清空</span>
        </div>
        <div v-for="i in cart.items" :key="i.dishId" class="cp-item">
          <span class="cp-name">{{ i.name }}</span>
          <span class="price">{{ (i.price * i.quantity).toFixed(2) }}</span>
          <div class="stepper">
            <van-icon name="minus" class="step-btn" @click="cart.minus(i.dishId)" />
            <span class="step-num">{{ i.quantity }}</span>
            <van-icon name="plus" class="step-btn add" @click="cart.add(shop.id, { id: i.dishId, name: i.name, image: i.image, price: i.price })" />
          </div>
        </div>
        <van-empty v-if="cart.items.length === 0" description="购物车空空如也" />
      </div>
    </van-popup>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showToast } from 'vant'
import { shopApi, reviewApi } from '../../api'
import { imgUrl } from '../../utils/request'
import { useCartStore } from '../../store/cart'

export default {
  name: 'ShopDetail',
  setup() {
    const route = useRoute()
    const router = useRouter()
    const cart = useCartStore()
    const shopId = Number(route.params.id)

    const shop = ref(null)
    const dishes = ref([])
    const reviews = ref([])
    const tab = ref(0)
    const showCart = ref(false)

    const getQuantity = (id) => cart.getQuantity(id)
    const addDish = (d) => {
      if (d.stock !== null && d.stock <= 0) {
        showToast('已售罄')
        return
      }
      cart.add(shopId, d)
    }

    const canSubmit = computed(() => {
      if (!shop.value) return false
      return cart.totalCount > 0 && Number(cart.totalPrice) >= Number(shop.value.minAmount)
    })
    const submitText = computed(() => {
      if (!shop.value) return '去结算'
      if (cart.totalCount === 0) return `起送 ¥${shop.value.minAmount}`
      const diff = Number(shop.value.minAmount) - Number(cart.totalPrice)
      return diff > 0 ? `还差 ¥${diff.toFixed(2)}起送` : '去结算'
    })

    const goConfirm = () => {
      if (!canSubmit.value) return
      router.push({ path: '/confirm' })
    }

    onMounted(async () => {
      const [detailRes, reviewRes] = await Promise.all([
        shopApi.detail(shopId),
        reviewApi.byShop(shopId, { page: 1, size: 20 })
      ])
      shop.value = detailRes.data.shop
      dishes.value = detailRes.data.dishes
      reviews.value = reviewRes.data.records
    })

    return {
      shop, dishes, reviews, tab, showCart, cart,
      imgUrl, getQuantity, addDish, canSubmit, submitText, goConfirm
    }
  }
}
</script>

<style scoped>
.shop-detail {
  padding-bottom: 70px;
}
.shop-header {
  display: flex;
  gap: 12px;
  padding: 16px;
  background: #fff;
}
.hd-name {
  font-size: 18px;
  font-weight: bold;
}
.hd-meta {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #969799;
  margin: 4px 0;
}
.hd-notice {
  font-size: 12px;
  color: #ff6b35;
}
.dish-list {
  padding: 8px 12px 0;
}
.dish-item {
  display: flex;
  gap: 12px;
  background: #fff;
  padding: 12px;
  border-radius: 10px;
  margin-bottom: 8px;
}
.dish-info {
  flex: 1;
}
.dish-name {
  font-size: 15px;
  font-weight: bold;
}
.dish-desc {
  font-size: 12px;
  color: #969799;
  margin: 4px 0;
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.dish-sales {
  font-size: 12px;
  color: #969799;
}
.dish-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 6px;
}
.stepper {
  display: flex;
  align-items: center;
  gap: 8px;
}
.step-btn {
  font-size: 22px;
  color: #ff6b35;
  border: 1px solid #ff6b35;
  border-radius: 50%;
  padding: 1px;
}
.step-btn.add {
  background: #ff6b35;
  color: #fff;
}
.step-num {
  min-width: 18px;
  text-align: center;
  font-size: 14px;
}
.review-list {
  padding: 12px;
}
.review-item {
  background: #fff;
  padding: 12px;
  border-radius: 10px;
  margin-bottom: 8px;
}
.rv-head {
  display: flex;
  align-items: center;
  gap: 8px;
}
.rv-name {
  font-size: 13px;
  font-weight: bold;
  flex: 1;
}
.rv-content {
  font-size: 13px;
  margin-top: 8px;
  color: #323233;
}
.rv-reply {
  font-size: 12px;
  color: #646566;
  background: #f7f8fa;
  padding: 8px;
  border-radius: 6px;
  margin-top: 8px;
}
.cart-bar {
  position: fixed;
  left: 12px;
  right: 12px;
  bottom: 12px;
  height: 50px;
  background: #333;
  border-radius: 25px;
  display: flex;
  align-items: center;
  padding: 0 8px 0 18px;
  z-index: 99;
}
.cart-left {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12px;
}
.cart-icon {
  font-size: 26px;
  color: #fff;
}
.cart-icon.empty {
  opacity: 0.5;
}
.cart-total .price {
  color: #fff;
  font-size: 18px;
}
.cart-submit {
  width: 120px;
  height: 40px;
}
.cart-submit.disabled {
  opacity: 0.6;
}
.cart-popup {
  padding: 16px;
  max-height: 50vh;
  overflow-y: auto;
}
.cp-head {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
  font-weight: bold;
  margin-bottom: 12px;
}
.cp-clear {
  color: #969799;
  font-weight: normal;
}
.cp-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 0;
}
.cp-name {
  flex: 1;
}
</style>
