<template>
  <div class="page">
    <van-nav-bar title="公告管理" />

    <div class="filter-bar">
      <van-search
        v-model="keyword"
        placeholder="搜索公告标题"
        shape="round"
        style="flex:1;padding:0"
        @search="reset"
        @clear="reset"
      />
    </div>

    <van-list v-model:loading="loading" :finished="finished" finished-text="没有更多了" @load="loadMore">
      <div v-for="n in notices" :key="n.id" class="notice-card">
        <div class="nc-title">{{ n.title }}</div>
        <div class="nc-content">{{ n.content }}</div>
        <div class="nc-foot">
          <span class="nc-time">{{ fmt(n.createTime) }}</span>
          <div class="nc-ops">
            <van-button size="mini" round plain @click="openEdit(n)">编辑</van-button>
            <van-button size="mini" round type="danger" plain @click="remove(n)">删除</van-button>
          </div>
        </div>
      </div>
      <van-empty v-if="!loading && notices.length === 0" description="暂无公告" />
    </van-list>

    <div class="fab" @click="openEdit()">
      <van-icon name="plus" />
    </div>

    <van-dialog v-model:show="show" :title="form.id ? '编辑公告' : '新增公告'" show-cancel-button @confirm="save">
      <div style="padding: 12px 16px">
        <van-field v-model="form.title" label="标题" placeholder="公告标题" />
        <van-field v-model="form.content" label="内容" rows="3" autosize type="textarea" placeholder="公告内容" />
      </div>
    </van-dialog>
  </div>
</template>

<script>
import { ref, reactive } from 'vue'
import { showConfirmDialog, showToast, showSuccessToast } from 'vant'
import { noticeApi } from '../../api'

export default {
  name: 'AdminNotices',
  setup() {
    const notices = ref([])
    const page = ref(0)
    const loading = ref(false)
    const finished = ref(false)
    const keyword = ref('')
    const show = ref(false)
    const form = reactive({ id: null, title: '', content: '' })

    const fmt = (t) => (t ? t.replace('T', ' ').slice(0, 16) : '')

    const loadMore = async () => {
      page.value += 1
      try {
        const { data } = await noticeApi.page({
          page: page.value,
          size: 10,
          keyword: keyword.value || undefined
        })
        notices.value.push(...data.records)
        if (notices.value.length >= data.total || data.records.length === 0) finished.value = true
      } catch (e) {
        finished.value = true
      } finally {
        loading.value = false
      }
    }

    const reset = () => {
      notices.value = []
      page.value = 0
      finished.value = false
      loading.value = true
      loadMore()
    }

    const openEdit = (n) => {
      if (n) Object.assign(form, n)
      else Object.assign(form, { id: null, title: '', content: '' })
      show.value = true
    }
    const save = async () => {
      if (!form.title || !form.content) {
        showToast('请填写标题和内容')
        return
      }
      await noticeApi.save({ ...form })
      showSuccessToast('保存成功')
      reset()
    }
    const remove = (n) => {
      showConfirmDialog({ title: '提示', message: `确定删除公告「${n.title}」吗？` })
        .then(async () => {
          await noticeApi.remove(n.id)
          showSuccessToast('已删除')
          reset()
        })
        .catch(() => {})
    }

    return { notices, loading, finished, keyword, show, form, fmt, loadMore, reset, openEdit, save, remove }
  }
}
</script>

<style scoped>
.notice-card {
  background: #fff;
  margin: 8px 12px;
  padding: 12px;
  border-radius: 10px;
}
.nc-title {
  font-size: 15px;
  font-weight: bold;
}
.nc-content {
  font-size: 13px;
  color: #646566;
  margin: 8px 0;
}
.nc-foot {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.nc-time {
  font-size: 12px;
  color: #969799;
}
.nc-ops {
  display: flex;
  gap: 8px;
}
.fab {
  position: fixed;
  right: 18px;
  bottom: 70px;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: #ff6b35;
  color: #fff;
  font-size: 26px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(255, 107, 53, 0.4);
  z-index: 90;
}
</style>
