<template>
  <div class="page">
    <div class="profile">
      <van-image
        round
        width="60"
        height="60"
        :src="imgUrl(user?.avatar)"
        fit="cover"
      />
      <div class="info">
        <div class="nick">{{ user?.nickname || user?.username }}</div>
        <div class="role">{{ roleText }}</div>
      </div>
    </div>

    <van-cell-group inset style="margin-top: 12px">
      <van-cell title="我的工作台" is-link icon="chart-trending-o" @click="goDashboard" />
      <van-cell
        v-if="role === 'USER'"
        title="收货地址"
        is-link
        icon="location-o"
        to="/address"
      />
      <van-cell
        v-if="role === 'MERCHANT'"
        title="店铺设置"
        is-link
        icon="shop-o"
        to="/m/shop"
      />
      <van-cell
        v-if="role === 'MERCHANT'"
        title="评价管理"
        is-link
        icon="comment-o"
        to="/m/reviews"
      />
    </van-cell-group>

    <van-cell-group inset style="margin-top: 12px">
      <van-cell title="修改密码" is-link icon="lock" to="/password" />
      <van-cell title="账号" :value="user?.username" icon="manager-o" />
      <van-cell title="手机号" :value="user?.phone || '未填写'" icon="phone-o" />
    </van-cell-group>

    <div style="padding: 24px 16px">
      <van-button round block type="danger" plain @click="onLogout">退出登录</van-button>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { showConfirmDialog } from 'vant'
import { useUserStore } from '../store/user'
import { imgUrl } from '../utils/request'

export default {
  name: 'Mine',
  setup() {
    const router = useRouter()
    const userStore = useUserStore()
    const user = computed(() => userStore.user)
    const role = computed(() => userStore.role)
    const roleMap = { USER: '普通用户', MERCHANT: '商家', ADMIN: '管理员' }
    const roleText = computed(() => roleMap[role.value] || '')

    const goDashboard = () => {
      const map = { USER: '/user-dashboard', MERCHANT: '/m/dashboard', ADMIN: '/a/dashboard' }
      router.push(map[role.value] || '/home')
    }

    const onLogout = () => {
      showConfirmDialog({ title: '提示', message: '确定退出登录吗？' })
        .then(() => {
          userStore.logout()
          router.replace('/login')
        })
        .catch(() => {})
    }

    return { user, role, roleText, imgUrl, goDashboard, onLogout }
  }
}
</script>

<style scoped>
.profile {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 24px 18px;
  background: linear-gradient(135deg, #ff8c42, #ff6b35);
  color: #fff;
}
.info .nick {
  font-size: 18px;
  font-weight: bold;
}
.info .role {
  font-size: 13px;
  opacity: 0.9;
  margin-top: 4px;
}
</style>
