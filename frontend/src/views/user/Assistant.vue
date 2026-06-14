<template>
  <div class="assistant-page">
    <van-nav-bar title="智能助手" />

    <!-- 消息列表：用户在右、助手在左，操作类回复下方展示「查看订单」入口 -->
    <div ref="listRef" class="msg-list">
      <div v-if="messages.length === 0" class="empty-tip">
        <div class="empty-title">你好，我是智能助手</div>
        <div class="empty-desc">可以用聊天直接帮你下单、查询订单、评价和退款</div>
      </div>

      <div
        v-for="(m, i) in messages"
        :key="i"
        class="msg-row"
        :class="m.role === 'user' ? 'is-user' : 'is-ai'"
      >
        <div class="bubble">
          <div class="bubble-text">{{ m.content }}</div>
          <div v-if="m.actions && m.actions.length" class="bubble-actions">
            <van-button
              v-for="(a, j) in m.actions"
              :key="j"
              size="mini"
              round
              type="primary"
              color="#ff6b35"
              @click="goAction(a)"
            >查看订单{{ a.orderNo ? ('（' + a.orderNo + '）') : '' }}</van-button>
          </div>

          <!-- 操作确认卡片：助手不直接执行写操作，由用户在此二次确认后再真正下单/退款/取消/评价 -->
          <div v-if="m.proposal" class="proposal-card" :class="'state-' + (m.proposal._state || 'pending')">
            <div class="pc-title">{{ m.proposal.title }}</div>
            <div class="pc-summary">{{ m.proposal.summary }}</div>
            <div v-if="(m.proposal._state || 'pending') === 'pending'" class="pc-btns">
              <van-button size="small" round type="primary" color="#ff6b35" @click="confirmProposal(m)">确认</van-button>
              <van-button size="small" round plain @click="cancelProposal(m)">取消</van-button>
            </div>
            <div v-else-if="m.proposal._state === 'done'" class="pc-status pc-done">已确认执行</div>
            <div v-else class="pc-status pc-cancelled">已取消该操作</div>
          </div>
        </div>
      </div>

      <div v-if="loading" class="msg-row is-ai">
        <div class="bubble">
          <div class="bubble-text thinking">正在处理…</div>
        </div>
      </div>
    </div>

    <!-- 快捷指令：点击即填充输入框，降低演示输入成本 -->
    <div class="quick-bar">
      <span
        v-for="(q, i) in quickCmds"
        :key="i"
        class="quick-chip"
        @click="useQuick(q)"
      >{{ q }}</span>
    </div>

    <!-- 输入区 -->
    <div class="input-bar">
      <van-field
        v-model="input"
        placeholder="说点什么，例如：帮我买一杯奶茶"
        @keyup.enter="send"
      />
      <van-button plain round size="small" color="#ff6b35" @click="showAiConfig = true">配置</van-button>
      <van-button
        type="primary"
        color="#ff6b35"
        :loading="loading"
        :disabled="!input.trim()"
        @click="send"
      >发送</van-button>
    </div>

    <van-dialog
      v-model:show="showAiConfig"
      title="配置 AI 助手"
      show-cancel-button
      confirm-button-text="保存"
      @confirm="saveAiConfig"
    >
      <div class="config-form">
        <van-field v-model="aiForm.apiUrl" label="接口地址" placeholder="OpenAI 兼容接口地址" />
        <van-field v-model="aiForm.apiPassword" label="口令" type="password" placeholder="填写 APIPassword 或 API Key" />
        <van-field v-model="aiForm.model" label="模型" placeholder="例如 generalv3" />
        <div class="config-link">
          申请地址：<a href="https://console.xfyun.cn/" target="_blank">讯飞开放平台控制台</a>
        </div>
      </div>
    </van-dialog>
  </div>
</template>

<script>
import { nextTick, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { showToast, showConfirmDialog, showSuccessToast } from 'vant'
import { aiApi, orderApi, reviewApi } from '../../api'

export default {
  name: 'Assistant',
  setup() {
    const router = useRouter()
    const messages = ref([]) // { role, content, actions? }
    const input = ref('')
    const loading = ref(false)
    const listRef = ref(null)
    const serverAiConfigured = ref(false)
    const showAiConfig = ref(false)
    const aiForm = reactive({
      apiUrl: localStorage.getItem('ai_api_url') || 'https://spark-api-open.xf-yun.com/v1/chat/completions',
      apiPassword: localStorage.getItem('ai_api_password') || '',
      model: localStorage.getItem('ai_model') || 'generalv3'
    })

    const quickCmds = [
      '帮我推荐并买一杯奶茶',
      '我最近的订单',
      '给最近完成的订单评价5星',
      '帮我退款最近的订单'
    ]

    onMounted(async () => {
      try {
        const res = await aiApi.config()
        serverAiConfigured.value = !!(res.data && res.data.configured)
      } catch (e) {
        serverAiConfigured.value = false
      }
      if (!serverAiConfigured.value && !localStorage.getItem('ai_api_password')) {
        showAiConfig.value = true
      }
    })

    // 滚动到底部，保证最新消息可见
    const scrollToBottom = () => {
      nextTick(() => {
        const el = listRef.value
        if (el) el.scrollTop = el.scrollHeight
      })
    }

    const useQuick = (q) => {
      input.value = q
    }

    const saveAiConfig = () => {
      if (!aiForm.apiUrl.trim() || !aiForm.apiPassword.trim() || !aiForm.model.trim()) {
        showToast('请填写完整 AI 配置')
        return false
      }
      localStorage.setItem('ai_api_url', aiForm.apiUrl.trim())
      localStorage.setItem('ai_api_password', aiForm.apiPassword.trim())
      localStorage.setItem('ai_model', aiForm.model.trim())
      showSuccessToast('AI 配置已保存')
      return true
    }

    const getAiConfig = () => ({
      apiUrl: localStorage.getItem('ai_api_url') || aiForm.apiUrl,
      apiPassword: localStorage.getItem('ai_api_password') || aiForm.apiPassword,
      model: localStorage.getItem('ai_model') || aiForm.model
    })

    const goAction = (a) => {
      if (a.orderId) router.push('/order/' + a.orderId)
    }

    // 执行已确认的提案：按类型分发到已有业务接口，写操作的唯一执行入口
    const execProposal = async (p) => {
      if (p.type === 'place_order') {
        const items = (p.payload.items || []).map((it) => ({ dishId: it.dishId, quantity: it.quantity }))
        const { data: orderId } = await orderApi.create({
          shopId: p.payload.shopId,
          addressId: p.payload.addressId,
          remark: p.payload.remark,
          items
        })
        await orderApi.pay(orderId)
        return { orderId }
      }
      if (p.type === 'refund_order') {
        await orderApi.refund(p.payload.orderId)
        return { orderId: p.payload.orderId }
      }
      if (p.type === 'cancel_order') {
        await orderApi.cancel(p.payload.orderId)
        return { orderId: p.payload.orderId }
      }
      if (p.type === 'review_order') {
        await reviewApi.create({ orderId: p.payload.orderId, rating: p.payload.rating, content: p.payload.content })
        return { orderId: p.payload.orderId }
      }
      return {}
    }

    // 确认提案后的回执文案
    const doneText = {
      place_order: '已为你下单并支付成功～',
      refund_order: '已为你提交退款～',
      cancel_order: '已为你取消订单～',
      review_order: '已提交评价，感谢反馈～'
    }

    // 点击「确认」：先弹二次确认对话框，确认后才真正调用接口执行
    const confirmProposal = (m) => {
      const p = m.proposal
      if (!p || p._state !== 'pending') return
      showConfirmDialog({ title: p.title, message: p.summary })
        .then(async () => {
          try {
            const r = await execProposal(p)
            p._state = 'done'
            showSuccessToast('操作成功')
            messages.value.push({
              role: 'assistant',
              content: doneText[p.type] || '操作已完成',
              actions: r.orderId ? [{ orderId: r.orderId, orderNo: p.payload.orderNo || '' }] : []
            })
            scrollToBottom()
          } catch (e) {
            // 业务异常已由 request 拦截器统一弹中文提示，此处不重复提示
          }
        })
        .catch(() => {})
    }

    // 点击「取消」：仅置卡片为已取消，不调用任何接口
    const cancelProposal = (m) => {
      const p = m.proposal
      if (!p || p._state !== 'pending') return
      p._state = 'cancelled'
      messages.value.push({ role: 'assistant', content: '已取消该操作，未做任何更改。' })
      scrollToBottom()
    }

    // 发送消息：把完整历史交给后端 Agent，渲染回复与已执行动作
    const send = async () => {
      const text = input.value.trim()
      if (!text || loading.value) return
      if (!serverAiConfigured.value && !localStorage.getItem('ai_api_password')) {
        showAiConfig.value = true
        showToast('请先配置 AI 口令')
        return
      }
      messages.value.push({ role: 'user', content: text })
      input.value = ''
      loading.value = true
      scrollToBottom()

      // 只发送 role/content，actions 仅用于前端渲染
      const history = messages.value.map((m) => ({ role: m.role, content: m.content }))
      try {
        const res = await aiApi.agent(history, getAiConfig())
        const data = res.data || {}
        messages.value.push({
          role: 'assistant',
          content: data.reply || '抱歉，我没有理解你的意思',
          actions: data.actions || [],
          // 后端返回的待确认提案：附加 _state 跟踪卡片状态（pending/done/cancelled）
          proposal: data.proposal ? { ...data.proposal, _state: 'pending' } : null
        })
      } catch (e) {
        showAiConfig.value = true
        showToast('请检查 AI 配置')
        messages.value.push({
          role: 'assistant',
          content: '智能助手暂时不可用，请先配置 AI 口令。申请地址：https://console.xfyun.cn/'
        })
      } finally {
        loading.value = false
        scrollToBottom()
      }
    }

    return {
      messages,
      input,
      loading,
      listRef,
      quickCmds,
      showAiConfig,
      aiForm,
      useQuick,
      saveAiConfig,
      goAction,
      confirmProposal,
      cancelProposal,
      send
    }
  }
}
</script>

<style scoped>
.assistant-page {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: #f5f5f5;
}
.msg-list {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
}
.empty-tip {
  text-align: center;
  color: #999;
  margin-top: 60px;
}
.empty-title {
  font-size: 18px;
  color: #333;
  margin-bottom: 8px;
}
.empty-desc {
  font-size: 13px;
}
.msg-row {
  display: flex;
  margin-bottom: 12px;
}
.msg-row.is-user {
  justify-content: flex-end;
}
.msg-row.is-ai {
  justify-content: flex-start;
}
.bubble {
  max-width: 76%;
  padding: 10px 12px;
  border-radius: 10px;
  font-size: 14px;
  line-height: 1.5;
  word-break: break-word;
}
.is-user .bubble {
  background: #ff6b35;
  color: #fff;
  border-top-right-radius: 2px;
}
.is-ai .bubble {
  background: #fff;
  color: #333;
  border-top-left-radius: 2px;
}
.bubble-text {
  white-space: pre-wrap;
}
.thinking {
  color: #999;
}
.bubble-actions {
  margin-top: 8px;
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}
.proposal-card {
  margin-top: 10px;
  padding: 10px 12px;
  background: #fff7e6;
  border: 1px solid #ffd591;
  border-radius: 8px;
}
.pc-title {
  font-weight: bold;
  color: #d46b08;
  margin-bottom: 6px;
}
.pc-summary {
  font-size: 13px;
  color: #614700;
  white-space: pre-wrap;
  line-height: 1.6;
}
.pc-btns {
  margin-top: 10px;
  display: flex;
  gap: 10px;
}
.pc-status {
  margin-top: 8px;
  font-size: 12px;
}
.pc-done {
  color: #07c160;
}
.pc-cancelled {
  color: #969799;
}
.quick-bar {
  display: flex;
  gap: 8px;
  padding: 8px 12px;
  overflow-x: auto;
  background: #fafafa;
  border-top: 1px solid #eee;
}
.quick-chip {
  flex: none;
  font-size: 12px;
  color: #ff6b35;
  background: #fff;
  border: 1px solid #ffd6c2;
  border-radius: 14px;
  padding: 5px 12px;
  white-space: nowrap;
}
.input-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #fff;
  border-top: 1px solid #eee;
  /* 底部导航栏占位，避免输入框被 tabbar 遮挡 */
  margin-bottom: 50px;
}
.input-bar .van-field {
  flex: 1;
  background: #f5f5f5;
  border-radius: 18px;
  padding: 4px 12px;
}
.config-form {
  padding: 12px 8px 4px;
}
.config-link {
  padding: 8px 16px 12px;
  font-size: 12px;
  color: #666;
}
.config-link a {
  color: #ff6b35;
}
</style>
