<template>
  <div class="page">
    <van-nav-bar title="店铺管理" />

    <div class="filter-bar">
      <van-search
        v-model="filter.keyword"
        placeholder="搜索店铺名"
        shape="round"
        style="flex:1;padding:0"
        @search="reset"
        @clear="reset"
      />
    </div>
    <div class="filter-bar" style="padding-top:0">
      <van-dropdown-menu active-color="#ff6b35">
        <van-dropdown-item v-model="filter.status" :options="statusOptions" @change="reset" />
      </van-dropdown-menu>
      <van-button size="small" plain round @click="resetFilter">重置</van-button>
    </div>

    <van-list v-model:loading="loading" :finished="finished" finished-text="没有更多了" @load="loadMore">
      <div v-for="s in shops" :key="s.id" class="shop-card">
        <van-image width="56" height="56" radius="8" :src="imgUrl(s.logo)" fit="cover" />
        <div class="sc-info">
          <div class="sc-name">{{ s.name }}</div>
          <div class="sc-sub">{{ s.description }}</div>
          <van-tag :type="statusTag(s.status).type">{{ statusTag(s.status).text }}</van-tag>
        </div>
        <div class="sc-ops">
          <template v-if="s.status === 0">
            <van-button size="mini" round type="primary" color="#ff6b35" @click="audit(s, 1)">通过</van-button>
            <van-button size="mini" round type="danger" plain @click="audit(s, 3)">驳回</van-button>
          </template>
          <template v-else>
            <van-button v-if="s.status === 1" size="mini" round plain @click="audit(s, 2)">停业</van-button>
            <van-button v-if="s.status === 2" size="mini" round plain @click="audit(s, 1)">恢复</van-button>
            <van-button size="mini" round type="danger" plain @click="remove(s)">删除</van-button>
          </template>
        </div>
      </div>
      <van-empty v-if="!loading && shops.length === 0" description="暂无店铺" />
    </van-list>
  </div>
</template>

<script>
import { ref, reactive } from 'vue'
import { showConfirmDialog, showSuccessToast } from 'vant'
import { shopApi } from '../../api'
import { imgUrl } from '../../utils/request'
import { SHOP_STATUS } from '../../utils/const'

export default {
  name: 'AdminShops',
  setup() {
    const shops = ref([])
    const page = ref(0)
    const loading = ref(false)
    const finished = ref(false)
    const filter = reactive({ keyword: '', status: -1 })
    const statusOptions = [
      { text: '全部状态', value: -1 },
      { text: '待审核', value: 0 },
      { text: '营业中', value: 1 },
      { text: '已停业', value: 2 },
      { text: '已驳回', value: 3 }
    ]

    const statusTag = (s) => {
      const map = { 0: { type: 'warning' }, 1: { type: 'success' }, 2: { type: 'default' }, 3: { type: 'danger' } }
      return { ...(map[s] || { type: 'default' }), text: SHOP_STATUS[s] || '' }
    }

    const loadMore = async () => {
      page.value += 1
      try {
        const { data } = await shopApi.adminList({
          page: page.value,
          size: 10,
          keyword: filter.keyword || undefined,
          status: filter.status === -1 ? undefined : filter.status
        })
        shops.value.push(...data.records)
        if (shops.value.length >= data.total || data.records.length === 0) finished.value = true
      } catch (e) {
        finished.value = true
      } finally {
        loading.value = false
      }
    }

    const reset = () => {
      shops.value = []
      page.value = 0
      finished.value = false
      loading.value = true
      loadMore()
    }
    const resetFilter = () => {
      filter.keyword = ''
      filter.status = -1
      reset()
    }

    const audit = async (s, status) => {
      await shopApi.audit(s.id, status)
      showSuccessToast('操作成功')
      reset()
    }
    const remove = (s) => {
      showConfirmDialog({ title: '提示', message: `确定删除店铺「${s.name}」吗？` })
        .then(async () => {
          await shopApi.remove(s.id)
          showSuccessToast('已删除')
          reset()
        })
        .catch(() => {})
    }

    return { shops, loading, finished, filter, statusOptions, imgUrl, statusTag, loadMore, reset, resetFilter, audit, remove }
  }
}
</script>

<style scoped>
.shop-card {
  display: flex;
  gap: 12px;
  background: #fff;
  margin: 8px 12px;
  padding: 12px;
  border-radius: 10px;
}
.sc-info {
  flex: 1;
  overflow: hidden;
}
.sc-name {
  font-size: 15px;
  font-weight: bold;
}
.sc-sub {
  font-size: 12px;
  color: #969799;
  margin: 6px 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.sc-ops {
  display: flex;
  flex-direction: column;
  gap: 6px;
  justify-content: center;
}
</style>
