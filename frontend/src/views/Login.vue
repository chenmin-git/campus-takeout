<template>
  <div class="login-page">
    <div class="brand">
      <img class="logo" src="../assets/logo.svg" alt="校园外卖" />
      <div class="title">校园外卖</div>
      <div class="sub">Campus Takeout</div>
    </div>

    <van-form @submit="onSubmit" class="form-card">
      <van-cell-group inset>
        <van-field
          v-model="form.username"
          name="username"
          label="账号"
          placeholder="请输入账号"
          :rules="[{ required: true, message: '请输入账号' }]"
        />
        <van-field
          v-model="form.password"
          type="password"
          name="password"
          label="密码"
          placeholder="请输入密码"
          :rules="[{ required: true, message: '请输入密码' }]"
        />
      </van-cell-group>

      <div class="form-btns">
        <van-button round block type="primary" native-type="submit" :loading="loading" color="#ff6b35">
          登 录
        </van-button>
        <div class="to-register">
          没有账号？<span @click="$router.push('/register')">立即注册</span>
        </div>
      </div>
    </van-form>

    <div class="demo-tip">
      <div class="demo-title">演示账号（密码均为 123456）</div>
      <div class="demo-row" @click="quick('admin')">管理员：admin</div>
      <div class="demo-row" @click="quick('merchant1')">商家：merchant1</div>
      <div class="demo-row" @click="quick('rider1')">配送员：rider1</div>
      <div class="demo-row" @click="quick('user1')">用户：user1</div>
    </div>
  </div>
</template>

<script>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { showSuccessToast } from 'vant'
import { authApi } from '../api'
import { useUserStore } from '../store/user'
import { roleHome } from '../router'

export default {
  name: 'Login',
  setup() {
    const router = useRouter()
    const userStore = useUserStore()
    const form = reactive({ username: '', password: '' })
    const loading = ref(false)

    const onSubmit = async () => {
      loading.value = true
      try {
        const { data } = await authApi.login(form)
        userStore.setLogin(data.token, data.user)
        showSuccessToast('登录成功')
        router.replace(roleHome[data.user.role] || '/home')
      } catch (e) {
        // 错误提示已由拦截器处理
      } finally {
        loading.value = false
      }
    }

    const quick = (username) => {
      form.username = username
      form.password = '123456'
    }

    return { form, loading, onSubmit, quick }
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  background: linear-gradient(160deg, #ff8c42 0%, #ff6b35 40%, #f5f6f8 40%);
  padding: 0 16px;
}
.brand {
  text-align: center;
  padding: 56px 0 28px;
  color: #fff;
}
.logo {
  width: 72px;
  height: 72px;
  display: block;
  margin: 0 auto;
}
.title {
  font-size: 26px;
  font-weight: bold;
  margin-top: 8px;
}
.sub {
  font-size: 13px;
  opacity: 0.85;
  margin-top: 4px;
}
.form-card {
  background: #fff;
  border-radius: 14px;
  padding: 18px 0 22px;
  box-shadow: 0 4px 18px rgba(0, 0, 0, 0.08);
}
.form-btns {
  padding: 18px 16px 0;
}
.to-register {
  text-align: center;
  font-size: 13px;
  color: #969799;
  margin-top: 14px;
}
.to-register span {
  color: #ff6b35;
}
.demo-tip {
  margin-top: 22px;
  background: #fff;
  border-radius: 12px;
  padding: 14px 16px;
  font-size: 13px;
  color: #646566;
}
.demo-title {
  font-weight: bold;
  margin-bottom: 8px;
  color: #323233;
}
.demo-row {
  padding: 6px 0;
  color: #ff6b35;
}
</style>
