<template>
  <div class="page">
    <van-nav-bar title="店铺设置" left-arrow @click-left="$router.back()" />

    <van-cell-group inset style="margin-top: 12px">
      <van-field v-model="form.name" label="店铺名称" placeholder="请输入店铺名称" />
      <van-field label="店铺分类" is-link readonly :model-value="categoryName" @click="showCat = true" placeholder="请选择分类" />
      <van-field v-model="form.description" label="简介" rows="2" autosize type="textarea" placeholder="店铺简介" />
      <van-field v-model="form.notice" label="公告" rows="2" autosize type="textarea" placeholder="店铺公告" />
      <van-field v-model="form.address" label="地址" placeholder="店铺地址" />
      <van-field v-model="form.deliveryFee" label="配送费" type="number" placeholder="配送费" />
      <van-field v-model="form.minAmount" label="起送价" type="number" placeholder="起送金额" />
    </van-cell-group>

    <van-cell-group inset style="margin-top: 12px">
      <van-field label="店铺Logo">
        <template #input>
          <van-uploader v-model="logoList" :max-count="1" :after-read="(f) => afterRead(f, 'logo')" />
        </template>
      </van-field>
      <van-field label="店铺封面">
        <template #input>
          <van-uploader v-model="coverList" :max-count="1" :after-read="(f) => afterRead(f, 'cover')" />
        </template>
      </van-field>
    </van-cell-group>

    <div v-if="form.id" class="status-tip">
      当前状态：<van-tag :type="statusTag.type">{{ statusTag.text }}</van-tag>
    </div>

    <div style="padding: 18px 16px">
      <van-button round block type="primary" color="#ff6b35" :loading="saving" @click="save">
        {{ form.id ? '保存修改' : '创建店铺' }}
      </van-button>
      <p class="create-tip" v-if="!form.id">创建后需管理员审核通过方可营业</p>
    </div>

    <!-- 分类选择 -->
    <van-popup v-model:show="showCat" position="bottom" round>
      <van-picker
        :columns="catColumns"
        @confirm="onCatConfirm"
        @cancel="showCat = false"
      />
    </van-popup>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from 'vue'
import { showToast, showSuccessToast } from 'vant'
import { shopApi, categoryApi, uploadApi } from '../../api'
import { imgUrl } from '../../utils/request'
import { SHOP_STATUS } from '../../utils/const'

export default {
  name: 'ShopSetting',
  setup() {
    const form = reactive({
      id: null, name: '', categoryId: null, description: '', notice: '',
      address: '', deliveryFee: '', minAmount: '', logo: '', cover: '', status: 0
    })
    const categories = ref([])
    const showCat = ref(false)
    const saving = ref(false)
    const logoList = ref([])
    const coverList = ref([])

    const categoryName = computed(() => {
      const c = categories.value.find((x) => x.id === form.categoryId)
      return c ? c.name : ''
    })
    const catColumns = computed(() => categories.value.map((c) => ({ text: c.name, value: c.id })))
    const statusTag = computed(() => {
      const map = { 0: { type: 'warning' }, 1: { type: 'success' }, 2: { type: 'default' }, 3: { type: 'danger' } }
      return { ...(map[form.status] || { type: 'default' }), text: SHOP_STATUS[form.status] || '' }
    })

    const onCatConfirm = ({ selectedOptions }) => {
      form.categoryId = selectedOptions[0].value
      showCat.value = false
    }

    const afterRead = async (file, field) => {
      file.status = 'uploading'
      file.message = '上传中'
      try {
        const { data } = await uploadApi.upload(file.file, 'shop')
        form[field] = data
        file.status = 'done'
      } catch (e) {
        file.status = 'failed'
        file.message = '失败'
      }
    }

    const save = async () => {
      if (!form.name || !form.categoryId) {
        showToast('请填写店铺名称并选择分类')
        return
      }
      saving.value = true
      try {
        await shopApi.save({ ...form })
        showSuccessToast('保存成功')
        await load()
      } catch (e) {
        // 拦截器提示
      } finally {
        saving.value = false
      }
    }

    const load = async () => {
      const { data } = await shopApi.mine()
      if (data) {
        Object.assign(form, data)
        logoList.value = data.logo ? [{ url: imgUrl(data.logo) }] : []
        coverList.value = data.cover ? [{ url: imgUrl(data.cover) }] : []
      }
    }

    onMounted(async () => {
      const catRes = await categoryApi.list()
      categories.value = catRes.data
      await load()
    })

    return {
      form, categories, showCat, saving, logoList, coverList,
      categoryName, catColumns, statusTag, onCatConfirm, afterRead, save
    }
  }
}
</script>

<style scoped>
.status-tip {
  padding: 12px 28px;
  font-size: 14px;
  color: #646566;
}
.create-tip {
  text-align: center;
  font-size: 12px;
  color: #969799;
  margin-top: 12px;
}
</style>
