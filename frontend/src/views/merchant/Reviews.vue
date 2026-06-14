<template>
  <div class="page">
    <van-nav-bar title="评价管理" left-arrow @click-left="$router.back()" />

    <van-list v-model:loading="loading" :finished="finished" finished-text="没有更多了" @load="loadMore">
      <div v-for="r in reviews" :key="r.review.id" class="review-card">
        <div class="rc-head">
          <van-image round width="34" height="34" :src="imgUrl(r.avatar)" />
          <span class="rc-name">{{ r.nickname }}</span>
          <van-rate :model-value="r.review.rating" readonly size="13" color="#ffb400" />
        </div>
        <div class="rc-content">{{ r.review.content }}</div>
        <div class="rc-time">{{ fmt(r.review.createTime) }}</div>
        <div v-if="r.review.reply" class="rc-reply">商家回复：{{ r.review.reply }}</div>
        <div v-else class="rc-action">
          <van-button size="small" round plain color="#ff6b35" @click="openReply(r)">回复</van-button>
        </div>
      </div>
      <van-empty v-if="!loading && reviews.length === 0" description="暂无评价" />
    </van-list>

    <van-dialog v-model:show="show" title="回复评价" show-cancel-button @confirm="submitReply">
      <van-field
        v-model="replyText"
        rows="3"
        autosize
        type="textarea"
        maxlength="100"
        placeholder="输入回复内容"
        show-word-limit
        style="padding: 12px 16px"
      />
    </van-dialog>
  </div>
</template>

<script>
import { ref } from 'vue'
import { showToast, showSuccessToast } from 'vant'
import { reviewApi } from '../../api'
import { imgUrl } from '../../utils/request'

export default {
  name: 'MerchantReviews',
  setup() {
    const reviews = ref([])
    const page = ref(0)
    const loading = ref(false)
    const finished = ref(false)
    const show = ref(false)
    const replyText = ref('')
    const current = ref(null)

    const fmt = (t) => (t ? t.replace('T', ' ').slice(0, 16) : '')

    const loadMore = async () => {
      page.value += 1
      try {
        const { data } = await reviewApi.merchantPage({ page: page.value, size: 10 })
        reviews.value.push(...data.records)
        if (reviews.value.length >= data.total || data.records.length === 0) finished.value = true
      } catch (e) {
        finished.value = true
      } finally {
        loading.value = false
      }
    }

    const reset = () => {
      reviews.value = []
      page.value = 0
      finished.value = false
      loading.value = true
      loadMore()
    }

    const openReply = (r) => {
      current.value = r
      replyText.value = ''
      show.value = true
    }
    const submitReply = async () => {
      if (!replyText.value.trim()) {
        showToast('请输入回复内容')
        return
      }
      await reviewApi.reply(current.value.review.id, replyText.value)
      showSuccessToast('回复成功')
      reset()
    }

    return { reviews, loading, finished, show, replyText, fmt, imgUrl, loadMore, openReply, submitReply }
  }
}
</script>

<style scoped>
.review-card {
  background: #fff;
  margin: 8px 12px;
  border-radius: 10px;
  padding: 12px;
}
.rc-head {
  display: flex;
  align-items: center;
  gap: 8px;
}
.rc-name {
  flex: 1;
  font-size: 14px;
  font-weight: bold;
}
.rc-content {
  font-size: 14px;
  margin-top: 10px;
}
.rc-time {
  font-size: 12px;
  color: #969799;
  margin-top: 6px;
}
.rc-reply {
  font-size: 13px;
  color: #646566;
  background: #f7f8fa;
  padding: 8px;
  border-radius: 6px;
  margin-top: 8px;
}
.rc-action {
  text-align: right;
  margin-top: 8px;
}
</style>
