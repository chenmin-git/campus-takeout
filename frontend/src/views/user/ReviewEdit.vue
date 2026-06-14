<template>
  <div class="page">
    <van-nav-bar title="发表评价" left-arrow @click-left="$router.back()" />

    <div class="rate-box">
      <span class="rate-label">综合评分</span>
      <van-rate v-model="form.rating" size="28" color="#ffb400" />
    </div>

    <van-cell-group inset style="margin-top: 12px">
      <van-field
        v-model="form.content"
        rows="4"
        autosize
        type="textarea"
        maxlength="200"
        placeholder="说说这次的用餐体验吧~"
        show-word-limit
      />
    </van-cell-group>

    <div style="padding: 24px 16px">
      <van-button round block type="primary" color="#ff6b35" :loading="loading" @click="onSubmit">
        提交评价
      </van-button>
    </div>
  </div>
</template>

<script>
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showToast, showSuccessToast } from 'vant'
import { reviewApi } from '../../api'

export default {
  name: 'ReviewEdit',
  setup() {
    const route = useRoute()
    const router = useRouter()
    const form = reactive({ orderId: Number(route.params.orderId), rating: 5, content: '' })
    const loading = ref(false)

    const onSubmit = async () => {
      if (!form.content.trim()) {
        showToast('请填写评价内容')
        return
      }
      loading.value = true
      try {
        await reviewApi.create(form)
        showSuccessToast('评价成功')
        router.back()
      } catch (e) {
        // 拦截器提示
      } finally {
        loading.value = false
      }
    }

    return { form, loading, onSubmit }
  }
}
</script>

<style scoped>
.rate-box {
  display: flex;
  align-items: center;
  gap: 16px;
  background: #fff;
  padding: 18px 16px;
  margin-top: 12px;
}
.rate-label {
  font-size: 15px;
  font-weight: bold;
}
</style>
