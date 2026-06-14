<template>
  <div class="page">
    <van-nav-bar title="菜品管理" />

    <van-empty v-if="loaded && !shopId" description="请先创建店铺">
      <van-button round type="primary" color="#ff6b35" @click="$router.push('/m/shop')">去创建</van-button>
    </van-empty>

    <template v-if="shopId">
      <!-- 筛选区 -->
      <div class="filter-bar">
        <van-search
          v-model="filter.keyword"
          placeholder="搜索菜品名"
          shape="round"
          style="flex:1;padding:0"
          @search="reset"
          @clear="reset"
        />
      </div>
      <div class="filter-bar" style="padding-top:0">
        <van-dropdown-menu active-color="#ff6b35">
          <van-dropdown-item v-model="filter.status" :options="statusOptions" @change="reset" />
          <van-dropdown-item v-model="filter.dishCategory" :options="catOptions" @change="reset" />
        </van-dropdown-menu>
        <van-button size="small" plain round @click="resetFilter">重置</van-button>
      </div>

      <!-- 列表 -->
      <van-list v-model:loading="loading" :finished="finished" finished-text="没有更多了" @load="loadMore">
        <div v-for="d in dishes" :key="d.id" class="dish-row">
          <van-image width="64" height="64" radius="8" :src="imgUrl(d.image)" fit="cover" />
          <div class="dr-info">
            <div class="dr-name">{{ d.name }}</div>
            <div class="dr-sub">{{ d.dishCategory }} · 库存 {{ d.stock }} · 月售 {{ d.sales }}</div>
            <div class="price">{{ Number(d.price).toFixed(2) }}</div>
          </div>
          <div class="dr-ops">
            <van-tag :type="d.status === 1 ? 'success' : 'default'">{{ d.status === 1 ? '在售' : '下架' }}</van-tag>
            <div class="dr-btns">
              <van-button size="mini" round @click="openEdit(d)">编辑</van-button>
              <van-button size="mini" round plain @click="toggleStatus(d)">{{ d.status === 1 ? '下架' : '上架' }}</van-button>
              <van-button size="mini" round type="danger" plain @click="remove(d)">删除</van-button>
            </div>
          </div>
        </div>
        <van-empty v-if="!loading && dishes.length === 0" description="暂无菜品" />
      </van-list>

      <!-- 新增浮动按钮 -->
      <div class="fab" @click="openEdit()">
        <van-icon name="plus" />
      </div>
    </template>

    <!-- 编辑弹窗 -->
    <van-popup v-model:show="show" position="bottom" round :style="{ height: '76%' }">
      <div class="edit-popup">
        <div class="ep-title">{{ form.id ? '编辑菜品' : '新增菜品' }}</div>
        <van-cell-group inset>
          <van-field v-model="form.name" label="名称" placeholder="菜品名称" />
          <van-field v-model="form.price" label="价格" type="number" placeholder="价格" />
          <van-field v-model="form.dishCategory" label="分类" placeholder="如 主食/饮品/小吃" />
          <van-field v-model="form.stock" label="库存" type="digit" placeholder="库存数量" />
          <van-field v-model="form.description" label="描述" rows="2" autosize type="textarea" placeholder="菜品描述" />
          <van-field label="图片">
            <template #input>
              <van-uploader
                v-model="fileList"
                :max-count="1"
                :after-read="afterRead"
              />
            </template>
          </van-field>
        </van-cell-group>
        <div style="padding: 18px 16px">
          <van-button round block type="primary" color="#ff6b35" :loading="saving" @click="save">保存</van-button>
        </div>
      </div>
    </van-popup>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { showConfirmDialog, showToast, showSuccessToast } from 'vant'
import { shopApi, dishApi, uploadApi } from '../../api'
import { imgUrl } from '../../utils/request'

export default {
  name: 'MerchantDishes',
  setup() {
    const shopId = ref(null)
    const loaded = ref(false)
    const dishes = ref([])
    const page = ref(0)
    const loading = ref(false)
    const finished = ref(false)

    const filter = reactive({ keyword: '', status: -1, dishCategory: '' })
    const statusOptions = [
      { text: '全部状态', value: -1 },
      { text: '在售', value: 1 },
      { text: '已下架', value: 0 }
    ]
    const catOptions = ref([{ text: '全部分类', value: '' }])

    const show = ref(false)
    const saving = ref(false)
    const form = reactive({ id: null, name: '', price: '', dishCategory: '', stock: 99, description: '', image: '', status: 1 })
    const fileList = ref([])

    const loadMore = async () => {
      page.value += 1
      try {
        const { data } = await dishApi.page({
          shopId: shopId.value,
          page: page.value,
          size: 10,
          keyword: filter.keyword || undefined,
          status: filter.status === -1 ? undefined : filter.status,
          dishCategory: filter.dishCategory || undefined
        })
        dishes.value.push(...data.records)
        if (dishes.value.length >= data.total || data.records.length === 0) finished.value = true
        // 收集分类用于筛选
        const cats = new Set(catOptions.value.map((c) => c.value))
        data.records.forEach((d) => {
          if (d.dishCategory && !cats.has(d.dishCategory)) {
            cats.add(d.dishCategory)
            catOptions.value.push({ text: d.dishCategory, value: d.dishCategory })
          }
        })
      } catch (e) {
        finished.value = true
      } finally {
        loading.value = false
      }
    }

    const reset = () => {
      dishes.value = []
      page.value = 0
      finished.value = false
      loading.value = true
      loadMore()
    }
    const resetFilter = () => {
      filter.keyword = ''
      filter.status = -1
      filter.dishCategory = ''
      reset()
    }

    const openEdit = (d) => {
      if (d) {
        Object.assign(form, d)
        fileList.value = d.image ? [{ url: imgUrl(d.image) }] : []
      } else {
        Object.assign(form, { id: null, name: '', price: '', dishCategory: '', stock: 99, description: '', image: '', status: 1 })
        fileList.value = []
      }
      show.value = true
    }

    const afterRead = async (file) => {
      file.status = 'uploading'
      file.message = '上传中'
      try {
        const { data } = await uploadApi.upload(file.file, 'dish')
        form.image = data
        file.status = 'done'
      } catch (e) {
        file.status = 'failed'
        file.message = '失败'
      }
    }

    const save = async () => {
      if (!form.name || !form.price) {
        showToast('请填写名称和价格')
        return
      }
      saving.value = true
      try {
        await dishApi.save({ ...form, shopId: shopId.value })
        showSuccessToast('保存成功')
        show.value = false
        reset()
      } catch (e) {
        // 拦截器提示
      } finally {
        saving.value = false
      }
    }

    const toggleStatus = async (d) => {
      await dishApi.status(d.id, d.status === 1 ? 0 : 1)
      showSuccessToast('操作成功')
      reset()
    }
    const remove = (d) => {
      showConfirmDialog({ title: '提示', message: `确定删除菜品「${d.name}」吗？` })
        .then(async () => {
          await dishApi.remove(d.id)
          showSuccessToast('已删除')
          reset()
        })
        .catch(() => {})
    }

    onMounted(async () => {
      const { data } = await shopApi.mine()
      loaded.value = true
      if (data) {
        shopId.value = data.id
        reset()
      }
    })

    return {
      shopId, loaded, dishes, loading, finished, filter, statusOptions, catOptions,
      show, saving, form, fileList,
      imgUrl, loadMore, reset, resetFilter, openEdit, afterRead, save, toggleStatus, remove
    }
  }
}
</script>

<style scoped>
.dish-row {
  display: flex;
  gap: 12px;
  background: #fff;
  margin: 8px 12px;
  padding: 12px;
  border-radius: 10px;
}
.dr-info {
  flex: 1;
}
.dr-name {
  font-size: 15px;
  font-weight: bold;
}
.dr-sub {
  font-size: 12px;
  color: #969799;
  margin: 6px 0;
}
.dr-ops {
  text-align: right;
}
.dr-btns {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-top: 8px;
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
.edit-popup {
  padding: 18px 0;
  height: 100%;
  overflow-y: auto;
}
.ep-title {
  text-align: center;
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 16px;
}
</style>
