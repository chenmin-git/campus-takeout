<template>
  <div class="page">
    <van-nav-bar title="收货地址" left-arrow @click-left="$router.back()" />

    <div class="addr-list">
      <div
        v-for="a in list"
        :key="a.id"
        class="addr-card"
        @click="onSelect(a)"
      >
        <div class="ac-main">
          <div class="ac-line">
            <span class="ac-name">{{ a.name }}</span>
            <span class="ac-phone">{{ a.phone }}</span>
            <van-tag v-if="a.isDefault === 1" type="primary" color="#ff6b35">默认</van-tag>
          </div>
          <div class="ac-detail">{{ a.detail }}</div>
        </div>
        <div class="ac-ops" @click.stop>
          <van-icon name="edit" @click="openEdit(a)" />
          <van-icon name="delete-o" @click="remove(a)" />
        </div>
      </div>
      <van-empty v-if="list.length === 0" description="暂无收货地址" />
    </div>

    <div class="add-btn">
      <van-button round block type="primary" color="#ff6b35" icon="plus" @click="openEdit()">
        新增地址
      </van-button>
    </div>

    <!-- 编辑弹窗 -->
    <van-popup v-model:show="show" position="bottom" round :style="{ height: '60%' }">
      <div class="edit-popup">
        <div class="ep-title">{{ form.id ? '编辑地址' : '新增地址' }}</div>
        <van-cell-group inset>
          <van-field v-model="form.name" label="联系人" placeholder="收货人姓名" />
          <van-field v-model="form.phone" label="手机号" placeholder="手机号" type="tel" />
          <van-field v-model="form.detail" label="地址" rows="2" autosize type="textarea" placeholder="详细地址（楼栋/宿舍/门牌号）" />
          <van-cell title="设为默认地址">
            <template #right-icon>
              <van-switch v-model="isDefault" size="20px" active-color="#ff6b35" />
            </template>
          </van-cell>
        </van-cell-group>
        <div style="padding: 18px 16px">
          <van-button round block type="primary" color="#ff6b35" @click="save">保存</van-button>
        </div>
      </div>
    </van-popup>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showConfirmDialog, showToast, showSuccessToast } from 'vant'
import { addressApi } from '../../api'

export default {
  name: 'Address',
  setup() {
    const route = useRoute()
    const router = useRouter()
    const selectMode = route.query.select === '1'
    const list = ref([])
    const show = ref(false)
    const form = reactive({ id: null, name: '', phone: '', detail: '', isDefault: 0 })
    const isDefault = computed({
      get: () => form.isDefault === 1,
      set: (v) => (form.isDefault = v ? 1 : 0)
    })

    const load = async () => {
      const { data } = await addressApi.list()
      list.value = data
    }

    const openEdit = (a) => {
      if (a) {
        Object.assign(form, a)
      } else {
        Object.assign(form, { id: null, name: '', phone: '', detail: '', isDefault: 0 })
      }
      show.value = true
    }

    const save = async () => {
      if (!form.name || !form.phone || !form.detail) {
        showToast('请填写完整信息')
        return
      }
      await addressApi.save({ ...form })
      showSuccessToast('保存成功')
      show.value = false
      load()
    }

    const remove = (a) => {
      showConfirmDialog({ title: '提示', message: '确定删除该地址吗？' })
        .then(async () => {
          await addressApi.remove(a.id)
          showSuccessToast('已删除')
          load()
        })
        .catch(() => {})
    }

    const onSelect = (a) => {
      if (selectMode) {
        router.replace({ path: '/confirm', query: { addressId: a.id } })
      }
    }

    onMounted(load)

    return { list, show, form, isDefault, openEdit, save, remove, onSelect }
  }
}
</script>

<style scoped>
.addr-list {
  padding: 12px;
}
.addr-card {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 10px;
  padding: 14px;
  margin-bottom: 10px;
}
.ac-main {
  flex: 1;
}
.ac-line {
  display: flex;
  align-items: center;
  gap: 8px;
}
.ac-name {
  font-size: 16px;
  font-weight: bold;
}
.ac-phone {
  color: #646566;
}
.ac-detail {
  font-size: 13px;
  color: #969799;
  margin-top: 6px;
}
.ac-ops {
  display: flex;
  gap: 16px;
  font-size: 20px;
  color: #969799;
}
.add-btn {
  padding: 16px;
}
.edit-popup {
  padding: 18px 0;
}
.ep-title {
  text-align: center;
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 16px;
}
</style>
