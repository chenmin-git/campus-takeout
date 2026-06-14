<template>
  <div class="page">
    <van-nav-bar title="用户管理" />

    <div class="filter-bar">
      <van-search
        v-model="filter.keyword"
        placeholder="搜索账号/昵称"
        shape="round"
        style="flex:1;padding:0"
        @search="reset"
        @clear="reset"
      />
    </div>
    <div class="filter-bar" style="padding-top:0">
      <van-dropdown-menu active-color="#ff6b35">
        <van-dropdown-item v-model="filter.role" :options="roleOptions" @change="reset" />
        <van-dropdown-item v-model="filter.status" :options="statusOptions" @change="reset" />
      </van-dropdown-menu>
      <van-button size="small" plain round @click="resetFilter">重置</van-button>
    </div>

    <van-list v-model:loading="loading" :finished="finished" finished-text="没有更多了" @load="loadMore">
      <div v-for="u in users" :key="u.id" class="user-card">
        <van-image round width="44" height="44" :src="imgUrl(u.avatar)" fit="cover" />
        <div class="uc-info">
          <div class="uc-name">
            {{ u.nickname || u.username }}
            <van-tag size="mini" :type="roleTagType(u.role)">{{ roleText(u.role) }}</van-tag>
          </div>
          <div class="uc-sub">@{{ u.username }} · {{ u.phone || '无手机号' }}</div>
        </div>
        <div class="uc-ops">
          <van-tag :type="u.status === 1 ? 'success' : 'danger'">{{ u.status === 1 ? '正常' : '禁用' }}</van-tag>
          <div class="uc-btns">
            <van-button size="mini" round plain @click="toggleStatus(u)">{{ u.status === 1 ? '禁用' : '启用' }}</van-button>
            <van-button size="mini" round plain @click="resetPwd(u)">重置密码</van-button>
            <van-button v-if="u.role !== 'ADMIN'" size="mini" round type="danger" plain @click="remove(u)">删除</van-button>
          </div>
        </div>
      </div>
      <van-empty v-if="!loading && users.length === 0" description="暂无用户" />
    </van-list>
  </div>
</template>

<script>
import { ref, reactive } from 'vue'
import { showConfirmDialog, showSuccessToast } from 'vant'
import { userApi } from '../../api'
import { imgUrl } from '../../utils/request'
import { ROLE_TEXT } from '../../utils/const'

export default {
  name: 'AdminUsers',
  setup() {
    const users = ref([])
    const page = ref(0)
    const loading = ref(false)
    const finished = ref(false)
    const filter = reactive({ keyword: '', role: '', status: -1 })
    const roleOptions = [
      { text: '全部角色', value: '' },
      { text: '用户', value: 'USER' },
      { text: '商家', value: 'MERCHANT' },
      { text: '管理员', value: 'ADMIN' }
    ]
    const statusOptions = [
      { text: '全部状态', value: -1 },
      { text: '正常', value: 1 },
      { text: '禁用', value: 0 }
    ]

    const roleText = (r) => ROLE_TEXT[r] || r
    const roleTagType = (r) => ({ USER: 'primary', MERCHANT: 'warning', ADMIN: 'danger' }[r] || 'default')

    const loadMore = async () => {
      page.value += 1
      try {
        const { data } = await userApi.page({
          page: page.value,
          size: 10,
          keyword: filter.keyword || undefined,
          role: filter.role || undefined,
          status: filter.status === -1 ? undefined : filter.status
        })
        users.value.push(...data.records)
        if (users.value.length >= data.total || data.records.length === 0) finished.value = true
      } catch (e) {
        finished.value = true
      } finally {
        loading.value = false
      }
    }

    const reset = () => {
      users.value = []
      page.value = 0
      finished.value = false
      loading.value = true
      loadMore()
    }
    const resetFilter = () => {
      filter.keyword = ''
      filter.role = ''
      filter.status = -1
      reset()
    }

    const toggleStatus = async (u) => {
      await userApi.status(u.id, u.status === 1 ? 0 : 1)
      showSuccessToast('操作成功')
      reset()
    }
    const resetPwd = (u) => {
      showConfirmDialog({ title: '提示', message: `将「${u.username}」密码重置为 123456？` })
        .then(async () => {
          await userApi.reset(u.id)
          showSuccessToast('已重置为 123456')
        })
        .catch(() => {})
    }
    const remove = (u) => {
      showConfirmDialog({ title: '提示', message: `确定删除用户「${u.username}」吗？` })
        .then(async () => {
          await userApi.remove(u.id)
          showSuccessToast('已删除')
          reset()
        })
        .catch(() => {})
    }

    return {
      users, loading, finished, filter, roleOptions, statusOptions,
      imgUrl, roleText, roleTagType, loadMore, reset, resetFilter, toggleStatus, resetPwd, remove
    }
  }
}
</script>

<style scoped>
.user-card {
  display: flex;
  gap: 12px;
  background: #fff;
  margin: 8px 12px;
  padding: 12px;
  border-radius: 10px;
}
.uc-info {
  flex: 1;
}
.uc-name {
  font-size: 15px;
  font-weight: bold;
  display: flex;
  align-items: center;
  gap: 6px;
}
.uc-sub {
  font-size: 12px;
  color: #969799;
  margin-top: 6px;
}
.uc-ops {
  text-align: right;
}
.uc-btns {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-top: 8px;
}
</style>
