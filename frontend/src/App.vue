<template>
  <div class="app-container">
    <router-view v-slot="{ Component }">
      <keep-alive :include="['Home']">
        <component :is="Component" />
      </keep-alive>
    </router-view>

    <!-- 底部导航：按角色显示不同菜单，仅在标记 tab 的页面显示 -->
    <van-tabbar
      v-if="showTab"
      v-model="active"
      route
      active-color="#ff6b35"
      inactive-color="#999"
    >
      <van-tabbar-item
        v-for="t in tabs"
        :key="t.path"
        :icon="t.icon"
        :to="t.path"
      >{{ t.title }}</van-tabbar-item>
    </van-tabbar>

  </div>
</template>

<script>
import { computed, ref } from 'vue'
import { useRoute } from 'vue-router'
import { useUserStore } from './store/user'

const TAB_CONFIG = {
  USER: [
    { title: '首页', icon: 'shop-o', path: '/home' },
    { title: '订单', icon: 'orders-o', path: '/orders' },
    { title: '助手', icon: 'chat-o', path: '/assistant' },
    { title: '我的', icon: 'user-o', path: '/mine' }
  ],
  MERCHANT: [
    { title: '工作台', icon: 'bar-chart-o', path: '/m/dashboard' },
    { title: '菜品', icon: 'goods-collect-o', path: '/m/dishes' },
    { title: '订单', icon: 'orders-o', path: '/m/orders' },
    { title: '我的', icon: 'user-o', path: '/mine' }
  ],
  ADMIN: [
    { title: '工作台', icon: 'bar-chart-o', path: '/a/dashboard' },
    { title: '店铺', icon: 'shop-o', path: '/a/shops' },
    { title: '订单', icon: 'orders-o', path: '/a/orders' },
    { title: '我的', icon: 'user-o', path: '/mine' }
  ],
  RIDER: [
    { title: '工作台', icon: 'bar-chart-o', path: '/r/dashboard' },
    { title: '抢单', icon: 'logistics', path: '/r/hall' },
    { title: '配送', icon: 'send-gift-o', path: '/r/orders' },
    { title: '我的', icon: 'user-o', path: '/mine' }
  ]
}

export default {
  name: 'App',
  setup() {
    const route = useRoute()
    const userStore = useUserStore()
    const active = ref(0)
    const tabs = computed(() => TAB_CONFIG[userStore.role] || [])
    const showTab = computed(() => route.meta.tab && userStore.isLogin)
    return { active, tabs, showTab }
  }
}
</script>
