import { defineStore } from 'pinia'

// 购物车：按店铺维度保存，切换店铺时清空旧店铺商品
export const useCartStore = defineStore('cart', {
  state: () => ({
    shopId: null,
    items: [] // { dishId, name, image, price, quantity }
  }),
  getters: {
    totalCount: (state) => state.items.reduce((s, i) => s + i.quantity, 0),
    totalPrice: (state) =>
      state.items.reduce((s, i) => s + i.price * i.quantity, 0).toFixed(2)
  },
  actions: {
    add(shopId, dish) {
      // 切换店铺则清空购物车
      if (this.shopId !== shopId) {
        this.shopId = shopId
        this.items = []
      }
      const exist = this.items.find((i) => i.dishId === dish.id)
      if (exist) {
        exist.quantity += 1
      } else {
        this.items.push({
          dishId: dish.id,
          name: dish.name,
          image: dish.image,
          price: dish.price,
          quantity: 1
        })
      }
    },
    minus(dishId) {
      const exist = this.items.find((i) => i.dishId === dishId)
      if (exist) {
        exist.quantity -= 1
        if (exist.quantity <= 0) {
          this.items = this.items.filter((i) => i.dishId !== dishId)
        }
      }
    },
    getQuantity(dishId) {
      const exist = this.items.find((i) => i.dishId === dishId)
      return exist ? exist.quantity : 0
    },
    clear() {
      this.shopId = null
      this.items = []
    }
  }
})
