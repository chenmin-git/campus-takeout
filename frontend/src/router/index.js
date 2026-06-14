import { createRouter, createWebHistory } from 'vue-router'

// 路由表：按角色划分用户端 / 商家端(/m) / 管理员端(/a)
const routes = [
  { path: '/login', component: () => import('../views/Login.vue'), meta: { public: true } },
  { path: '/register', component: () => import('../views/Register.vue'), meta: { public: true } },

  // 用户端
  { path: '/home', component: () => import('../views/user/Home.vue'), meta: { tab: true, role: 'USER' } },
  { path: '/shop/:id', component: () => import('../views/user/ShopDetail.vue'), meta: { role: 'USER' } },
  { path: '/confirm', component: () => import('../views/user/OrderConfirm.vue'), meta: { role: 'USER' } },
  { path: '/orders', component: () => import('../views/user/Orders.vue'), meta: { tab: true, role: 'USER' } },
  { path: '/order/:id', component: () => import('../views/user/OrderDetail.vue'), meta: { role: 'USER' } },
  { path: '/assistant', component: () => import('../views/user/Assistant.vue'), meta: { tab: true, role: 'USER' } },
  { path: '/review/:orderId', component: () => import('../views/user/ReviewEdit.vue'), meta: { role: 'USER' } },
  { path: '/address', component: () => import('../views/user/Address.vue'), meta: { role: 'USER' } },
  { path: '/user-dashboard', component: () => import('../views/user/Dashboard.vue'), meta: { role: 'USER' } },

  // 商家端
  { path: '/m/dashboard', component: () => import('../views/merchant/Dashboard.vue'), meta: { tab: true, role: 'MERCHANT' } },
  { path: '/m/dishes', component: () => import('../views/merchant/Dishes.vue'), meta: { tab: true, role: 'MERCHANT' } },
  { path: '/m/orders', component: () => import('../views/merchant/Orders.vue'), meta: { tab: true, role: 'MERCHANT' } },
  { path: '/m/reviews', component: () => import('../views/merchant/Reviews.vue'), meta: { role: 'MERCHANT' } },
  { path: '/m/shop', component: () => import('../views/merchant/ShopSetting.vue'), meta: { role: 'MERCHANT' } },

  // 管理员端
  { path: '/a/dashboard', component: () => import('../views/admin/Dashboard.vue'), meta: { tab: true, role: 'ADMIN' } },
  { path: '/a/shops', component: () => import('../views/admin/Shops.vue'), meta: { tab: true, role: 'ADMIN' } },
  { path: '/a/orders', component: () => import('../views/admin/Orders.vue'), meta: { tab: true, role: 'ADMIN' } },
  { path: '/a/users', component: () => import('../views/admin/Users.vue'), meta: { role: 'ADMIN' } },
  { path: '/a/categories', component: () => import('../views/admin/Categories.vue'), meta: { role: 'ADMIN' } },
  { path: '/a/notices', component: () => import('../views/admin/Notices.vue'), meta: { role: 'ADMIN' } },

  // 配送员端
  { path: '/r/dashboard', component: () => import('../views/rider/Dashboard.vue'), meta: { tab: true, role: 'RIDER' } },
  { path: '/r/hall', component: () => import('../views/rider/Hall.vue'), meta: { tab: true, role: 'RIDER' } },
  { path: '/r/orders', component: () => import('../views/rider/Orders.vue'), meta: { tab: true, role: 'RIDER' } },
  { path: '/r/order/:id', component: () => import('../views/rider/Delivery.vue'), meta: { role: 'RIDER' } },

  // 个人中心（多角色共用）
  { path: '/mine', component: () => import('../views/Mine.vue'), meta: { tab: true } },
  { path: '/password', component: () => import('../views/Password.vue') },

  { path: '/', redirect: '/login' },
  { path: '/:pathMatch(.*)*', component: () => import('../views/NotFound.vue'), meta: { public: true } }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 登录角色对应的首页
export const roleHome = {
  USER: '/home',
  MERCHANT: '/m/dashboard',
  ADMIN: '/a/dashboard',
  RIDER: '/r/dashboard'
}

// 全局守卫：未登录跳登录页；登录后按角色限制访问
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  const user = JSON.parse(localStorage.getItem('user') || 'null')
  if (to.meta.public) {
    return next()
  }
  if (!token || !user) {
    return next('/login')
  }
  // 角色不匹配的页面，跳回自己的首页
  if (to.meta.role && to.meta.role !== user.role) {
    return next(roleHome[user.role] || '/login')
  }
  next()
})

export default router
