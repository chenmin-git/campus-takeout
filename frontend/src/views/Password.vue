<template>
  <div class="page">
    <van-nav-bar title="修改密码" left-arrow @click-left="$router.back()" />

    <van-form @submit="onSubmit" style="margin-top: 12px">
      <van-cell-group inset>
        <van-field
          v-model="form.oldPassword"
          type="password"
          label="原密码"
          placeholder="请输入原密码"
          :rules="[{ required: true, message: '请输入原密码' }]"
        />
        <van-field
          v-model="form.newPassword"
          type="password"
          label="新密码"
          placeholder="请输入新密码"
          :rules="[{ required: true, message: '请输入新密码' }, { validator: v => v.length >= 6, message: '密码至少6位' }]"
        />
        <van-field
          v-model="confirm"
          type="password"
          label="确认密码"
          placeholder="请再次输入新密码"
          :rules="[{ validator: v => v === form.newPassword, message: '两次密码不一致' }]"
        />
      </van-cell-group>

      <div style="padding: 18px 16px">
        <van-button round block type="primary" native-type="submit" :loading="loading" color="#ff6b35">
          确认修改
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

export default {
  name: 'Password',
  setup() {
    const router = useRouter()
    const userStore = useUserStore()
    const form = reactive({ oldPassword: '', newPassword: '' })
    const confirm = ref('')
    const loading = ref(false)

    const onSubmit = async () => {
      loading.value = true
      try {
        await authApi.updatePassword(form)
        showSuccessToast('修改成功，请重新登录')
        userStore.logout()
        router.replace('/login')
      } catch (e) {
        // 拦截器已提示
      } finally {
        loading.value = false
      }
    }

    return { form, confirm, loading, onSubmit }
  }
}
</script>
