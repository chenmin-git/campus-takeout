<template>
  <div class="page">
    <van-nav-bar title="校园外卖" />

    <van-search
      v-model="keyword"
      placeholder="搜索店铺"
      shape="round"
      background="#fff"
      @search="onSearch"
      @clear="onSearch"
    />

    <!-- 公告 -->
    <van-notice-bar
      v-if="notices.length"
      left-icon="volume-o"
      :text="noticeText"
      color="#ff6b35"
      background="#fff7f2"
    />

    <!-- 分类导航 -->
    <div class="cat-grid">
      <div
        class="cat-item"
        :class="{ active: activeCat === null }"
        @click="selectCat(null)"
      >
        <div class="cat-icon"><van-icon name="apps-o" /></div>
        <div class="cat-name">全部</div>
      </div>
      <div
        v-for="c in categories"
        :key="c.id"
        class="cat-item"
        :class="{ active: activeCat === c.id }"
        @click="selectCat(c.id)"
      >
        <van-image width="38" height="38" :src="imgUrl(c.icon)" />
        <div class="cat-name">{{ c.name }}</div>
      </div>
    </div>

    <!-- 店铺列表 -->
    <van-list
      v-model:loading="loading"
      :finished="finished"
      finished-text="没有更多了"
      @load="loadMore"
    >
      <div
        v-for="s in shops"
        :key="s.id"
        class="shop-card"
        @click="$router.push('/shop/' + s.id)"
      >
        <van-image width="72" height="72" radius="8" :src="imgUrl(s.logo)" fit="cover" />
        <div class="shop-info">
          <div class="shop-name">{{ s.name }}</div>
          <div class="shop-desc">{{ s.description }}</div>
          <div class="shop-meta">
            <van-rate :model-value="Number(s.rating)" readonly size="12" color="#ffb400" allow-half />
            <span class="rating-num">{{ Number(s.rating).toFixed(1) }}</span>
            <span class="sales">月售 {{ s.sales }}</span>
          </div>
          <div class="shop-fee">起送 ¥{{ s.minAmount }} · 配送 ¥{{ s.deliveryFee }}</div>
        </div>
      </div>
    </van-list>

    <van-empty v-if="!loading && shops.length === 0" description="暂无店铺" />
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { shopApi, categoryApi, noticeApi } from '../../api'
import { imgUrl } from '../../utils/request'

export default {
  name: 'Home',
  setup() {
    const keyword = ref('')
    const shops = ref([])
    const categories = ref([])
    const notices = ref([])
    const activeCat = ref(null)
    const page = ref(0)
    const size = 10
    const total = ref(0)
    const loading = ref(false)
    const finished = ref(false)

    const noticeText = computed(() => notices.value.map((n) => n.title).join('　|　'))

    const loadMore = async () => {
      page.value += 1
      try {
        const { data } = await shopApi.list({
          page: page.value,
          size,
          keyword: keyword.value || undefined,
          categoryId: activeCat.value || undefined
        })
        shops.value.push(...data.records)
        total.value = data.total
        if (shops.value.length >= data.total || data.records.length === 0) {
          finished.value = true
        }
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

    const onSearch = () => reset()
    const selectCat = (id) => {
      activeCat.value = id
      reset()
    }

    onMounted(async () => {
      const [catRes, noticeRes] = await Promise.all([
        categoryApi.list(),
        noticeApi.latest()
      ])
      categories.value = catRes.data
      notices.value = noticeRes.data
    })

    return {
      keyword, shops, categories, notices, activeCat,
      loading, finished, noticeText, imgUrl,
      loadMore, onSearch, selectCat
    }
  }
}
</script>

<style scoped>
.cat-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 8px;
  background: #fff;
  padding: 14px 10px;
  margin-bottom: 8px;
}
.cat-item {
  text-align: center;
  font-size: 12px;
}
.cat-item .cat-icon {
  font-size: 32px;
  line-height: 38px;
  height: 38px;
  color: #ff8a4c;
}
.cat-item .cat-name {
  margin-top: 4px;
  color: #646566;
}
.cat-item.active .cat-name {
  color: #ff6b35;
  font-weight: bold;
}
.shop-card {
  display: flex;
  gap: 12px;
  background: #fff;
  margin: 8px 10px;
  padding: 12px;
  border-radius: 10px;
}
.shop-info {
  flex: 1;
  overflow: hidden;
}
.shop-name {
  font-size: 16px;
  font-weight: bold;
}
.shop-desc {
  font-size: 12px;
  color: #969799;
  margin: 4px 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.shop-meta {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #969799;
}
.rating-num {
  color: #ffb400;
}
.shop-fee {
  font-size: 12px;
  color: #969799;
  margin-top: 4px;
}
</style>
