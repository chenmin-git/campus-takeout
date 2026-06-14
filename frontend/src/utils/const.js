// 订单状态映射：与后端一致 1待支付 2待接单 3待配送 4配送中 5已完成 6已取消
export const ORDER_STATUS = {
  1: '待支付',
  2: '待接单',
  3: '待配送',
  4: '配送中',
  5: '已完成',
  6: '已取消'
}

// 店铺状态：0待审核 1营业 2停业 3已驳回
export const SHOP_STATUS = {
  0: '待审核',
  1: '营业中',
  2: '已停业',
  3: '已驳回'
}

// 角色映射
export const ROLE_TEXT = {
  USER: '普通用户',
  MERCHANT: '商家',
  ADMIN: '管理员',
  RIDER: '配送员'
}

// 配送延期申请状态：0无 1待用户审批 2已同意 3已拒绝
export const EXTEND_STATUS = {
  1: '待审批',
  2: '已同意',
  3: '已拒绝'
}

// 把两位数补零，用于时间显示
function pad (n) {
  return n < 10 ? '0' + n : '' + n
}

/**
 * 配送时效文案：根据截止时间返回剩余/超时描述，供用户端与骑手端实时展示。
 * @param {string} deadline 后端下发的 slaDeadline（如 '2026-06-13 12:30:00'）
 * @returns {{text:string, overtime:boolean}} text 展示文案；overtime 是否已超时
 */
export function slaText (deadline) {
  if (!deadline) return { text: '未开始计时', overtime: false }
  // 兼容 iOS：把 '2026-06-13 12:30:00' 中的空格替换为 'T'
  const end = new Date(String(deadline).replace(' ', 'T')).getTime()
  if (isNaN(end)) return { text: '未开始计时', overtime: false }
  const diff = end - Date.now()
  const hh = pad(new Date(end).getHours())
  const mm = pad(new Date(end).getMinutes())
  if (diff <= 0) {
    const over = Math.ceil(-diff / 60000)
    return { text: `已超时约 ${over} 分钟（预计 ${hh}:${mm} 送达）`, overtime: true }
  }
  const left = Math.ceil(diff / 60000)
  return { text: `剩余约 ${left} 分钟（${hh}:${mm} 前送达）`, overtime: false }
}
