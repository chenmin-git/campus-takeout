<template>
  <div class="page">
    <van-nav-bar title="注册" left-arrow @click-left="$router.back()" />

    <van-form @submit="onSubmit" style="margin-top: 12px">
      <van-cell-group inset>
        <van-field
          v-model="form.username"
          label="账号"
          placeholder="请输入账号"
          :rules="[{ required: true, message: '请输入账号' }]"
        />
        <van-field
          v-model="form.password"
          type="password"
          label="密码"
          placeholder="请输入密码"
          :rules="[{ required: true, message: '请输入密码' }]"
        />
        <van-field
          v-model="form.nickname"
          label="昵称"
          placeholder="选填，默认与账号相同"
        />
        <van-field
          v-model="form.phone"
          label="手机号"
          placeholder="请输入手机号"
          :rules="[{ pattern: /^1\d{10}$/, message: '手机号格式不正确' }]"
        />
        <van-field name="role" label="注册身份">
          <template #input>
            <van-radio-group v-model="form.role" direction="horizontal">
              <van-radio name="USER">普通用户</van-radio>
              <van-radio name="MERCHANT">商家</van-radio>
            </van-radio-group>
          </template>
        </van-field>
      </van-cell-group>

      <div style="padding: 18px 16px">
        <van-button round block type="primary" native-type="submit" :loading="loading" color="#ff6b35">
          注 册
        </van-button>
      </div>
    </van-form>
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
  name: 'Register',
  setup() {
    const router = useRouter()
    const userStore = useUserStore()
    const form = reactive({ username: '', password: '', nickname: '', phone: '', role: 'USER' })
    const loading = ref(false)

    const onSubmit = async () => {
      loading.value = true
      try {
        const { data } = await authApi.register(form)
        userStore.setLogin(data.token, data.user)
        showSuccessToast('注册成功')
        router.replace(roleHome[data.user.role] || '/home')
      } catch (e) {
        // 拦截器已提示
      } finally {
        loading.value = false
      }
    }

    return { form, loading, onSubmit }
  }
}
</script>
