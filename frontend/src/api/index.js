import request from '../utils/request'

// ============ 认证 ============
export const authApi = {
  login: (data) => request.post('/auth/login', data),
  register: (data) => request.post('/auth/register', data),
  info: () => request.get('/auth/info'),
  updatePassword: (data) => request.put('/auth/password', data)
}

// ============ 店铺 ============
export const shopApi = {
  list: (params) => request.get('/shop/list', { params }),
  adminList: (params) => request.get('/shop/admin/list', { params }),
  detail: (id) => request.get('/shop/detail/' + id),
  mine: () => request.get('/shop/mine'),
  save: (data) => request.post('/shop/save', data),
  audit: (id, status) => request.put(`/shop/audit/${id}/${status}`),
  remove: (id) => request.delete('/shop/' + id)
}

// ============ 菜品 ============
export const dishApi = {
  page: (params) => request.get('/dish/page', { params }),
  save: (data) => request.post('/dish/save', data),
  remove: (id) => request.delete('/dish/' + id),
  status: (id, status) => request.put(`/dish/status/${id}/${status}`)
}

// ============ 订单 ============
export const orderApi = {
  create: (data) => request.post('/order/create', data),
  pay: (id) => request.put('/order/pay/' + id),
  cancel: (id) => request.put('/order/cancel/' + id),
  confirm: (id) => request.put('/order/confirm/' + id),
  advance: (id, status) => request.put(`/order/advance/${id}/${status}`),
  userPage: (params) => request.get('/order/user/page', { params }),
  merchantPage: (params) => request.get('/order/merchant/page', { params }),
  adminPage: (params) => request.get('/order/admin/page', { params }),
  refund: (id) => request.put('/order/refund/' + id),
  detail: (id) => request.get('/order/detail/' + id),
  // 配送员：抢单大厅、抢单、我的配送、送达
  riderAvailable: (params) => request.get('/order/rider/available', { params }),
  riderPage: (params) => request.get('/order/rider/page', { params }),
  riderGrab: (id) => request.put('/order/rider/grab/' + id),
  riderDeliver: (id) => request.put('/order/rider/deliver/' + id),
  // 配送时效：骑手申请延期（body { minutes, reason }）、用户审批（approve=1同意/0拒绝）
  riderRequestExtend: (id, data) => request.put('/order/rider/extend/' + id, data),
  decideExtend: (id, approve) => request.put(`/order/extend/${id}/${approve}`)
}

// ============ 地址 ============
export const addressApi = {
  list: () => request.get('/address/list'),
  save: (data) => request.post('/address/save', data),
  remove: (id) => request.delete('/address/' + id)
}

// ============ 评价 ============
export const reviewApi = {
  create: (data) => request.post('/review/create', data),
  byShop: (shopId, params) => request.get('/review/shop/' + shopId, { params }),
  merchantPage: (params) => request.get('/review/merchant/page', { params }),
  reply: (id, reply) => request.put('/review/reply/' + id, { reply })
}

// ============ 分类 ============
export const categoryApi = {
  list: () => request.get('/category/list'),
  save: (data) => request.post('/category/save', data),
  remove: (id) => request.delete('/category/' + id)
}

// ============ 公告 ============
export const noticeApi = {
  latest: () => request.get('/notice/latest'),
  page: (params) => request.get('/notice/page', { params }),
  save: (data) => request.post('/notice/save', data),
  remove: (id) => request.delete('/notice/' + id)
}

// ============ 用户管理 ============
export const userApi = {
  page: (params) => request.get('/user/page', { params }),
  status: (id, status) => request.put(`/user/status/${id}/${status}`),
  reset: (id) => request.put('/user/reset/' + id),
  remove: (id) => request.delete('/user/' + id)
}

// ============ 统计 ============
export const statsApi = {
  admin: () => request.get('/stats/admin'),
  merchant: () => request.get('/stats/merchant'),
  user: () => request.get('/stats/user'),
  rider: () => request.get('/stats/rider')
}

// ============ 智能助手 ============
export const aiApi = {
  config: () => request.get('/ai/config'),
  // messages: [{ role: 'user' | 'assistant', content }]
  chat: (messages, config = {}) => request.post('/ai/chat', { messages, ...config }),
  // Agent 对话：可执行下单/查询/评价/退款等操作，返回 { reply, actions }
  agent: (messages, config = {}) => request.post('/ai/agent', { messages, ...config })
}

// ============ 文件上传 ============
export const uploadApi = {
  // module 用于归类存储目录，如 dish / shop / avatar
  upload: (file, module = 'common') => {
    const fd = new FormData()
    fd.append('file', file)
    return request.post('/upload?module=' + module, fd, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
}
