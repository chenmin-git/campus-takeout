<template>
  <div class="page">
    <van-nav-bar title="分类管理" />

    <div class="cat-list">
      <div v-for="c in list" :key="c.id" class="cat-card">
        <van-image width="40" height="40" :src="imgUrl(c.icon)" />
        <span class="cc-name">{{ c.name }}</span>
        <span class="cc-sort">排序 {{ c.sort }}</span>
        <div class="cc-ops">
          <van-icon name="edit" @click="openEdit(c)" />
          <van-icon name="delete-o" @click="remove(c)" />
        </div>
      </div>
      <van-empty v-if="list.length === 0" description="暂无分类" />
    </div>

    <div class="add-btn">
      <van-button round block type="primary" color="#ff6b35" icon="plus" @click="openEdit()">新增分类</van-button>
    </div>

    <van-dialog v-model:show="show" :title="form.id ? '编辑分类' : '新增分类'" show-cancel-button @confirm="save">
      <div style="padding: 12px 16px">
        <van-field v-model="form.name" label="名称" placeholder="分类名称" />
        <van-field v-model="form.icon" label="图标路径" placeholder="如 uploads/category/xx.svg" />
        <van-field v-model="form.sort" label="排序" type="digit" placeholder="数字越小越靠前" />
      </div>
    </van-dialog>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { showConfirmDialog, showToast, showSuccessToast } from 'vant'
import { categoryApi } from '../../api'
import { imgUrl } from '../../utils/request'

export default {
  name: 'AdminCategories',
  setup() {
    const list = ref([])
    const show = ref(false)
    const form = reactive({ id: null, name: '', icon: '', sort: 0 })

    const load = async () => {
      const { data } = await categoryApi.list()
      list.value = data
    }
    const openEdit = (c) => {
      if (c) Object.assign(form, c)
      else Object.assign(form, { id: null, name: '', icon: '', sort: 0 })
      show.value = true
    }
    const save = async () => {
      if (!form.name) {
        showToast('请填写分类名称')
        return
      }
      await categoryApi.save({ ...form })
      showSuccessToast('保存成功')
      load()
    }
    const remove = (c) => {
      showConfirmDialog({ title: '提示', message: `确定删除分类「${c.name}」吗？` })
        .then(async () => {
          await categoryApi.remove(c.id)
          showSuccessToast('已删除')
          load()
        })
        .catch(() => {})
    }

    onMounted(load)

    return { list, show, form, imgUrl, openEdit, save, remove }
  }
}
</script>

<style scoped>
.cat-list {
  padding: 12px;
}
.cat-card {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #fff;
  padding: 12px 14px;
  border-radius: 10px;
  margin-bottom: 8px;
}
.cc-name {
  flex: 1;
  font-size: 15px;
  font-weight: bold;
}
.cc-sort {
  font-size: 12px;
  color: #969799;
}
.cc-ops {
  display: flex;
  gap: 14px;
  font-size: 20px;
  color: #969799;
}
.add-btn {
  padding: 16px;
}
</style>
