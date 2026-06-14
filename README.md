# 校园外卖系统（H5 移动端）

基于 **Spring Boot + Vue3 + MySQL** 的校园外卖点餐系统，前端为 H5 移动端，适合在浏览器手机视图下演示。包含 **用户 / 商家 / 配送员 / 管理员** 四端，各端有差异化的 ECharts 数据工作台。配送环节接入 **高德地图** 展示骑手配送路线。

## 技术栈

| 层 | 技术 |
|---|---|
| 后端 | Spring Boot 3.4.1、MyBatis-Plus 3.5.9、JWT(jjwt)、Hutool、MySQL 驱动 |
| 前端 | Vue 3、Vant 4、Vue Router 4、Pinia、ECharts 5、Vite 6、Axios、高德地图 JSAPI 2.0 |
| 数据库 | MySQL 9.x，库名 `campus_takeout` |
| 运行环境 | JDK 21、Node 22、Maven 3.9 |

- 后端端口：**8090**
- 前端端口：**5175**（Vite 代理 `/api`、`/uploads` 到后端）
- 图片本地存储于 `uploads/`，数据库只存相对路径（如 `uploads/dish/xxx.jpg`），不依赖任何外部 CDN。演示图片为按业务主题（菜品/店铺/分类/头像）下载到本地的真实图片。

## 演示素材

- 竖屏 H5 演示视频：`docs/campus-takeout-ai-h5-demo.mp4`
- 功能截图目录：`docs/demo-screenshots/`
- 视频工程：`demo-video/`，画面顺序与讲解文案在 `demo-video/public/full-demo-scenes.json`、`demo-video/public/full-demo-captions.json`

演示视频重点覆盖系统框架、用户点餐、AI 助手下单/查询/评价/退款提案、商家管理、骑手配送地图、管理员审核与统计。

### 截图预览

| 登录与角色入口 | 用户首页 | AI 下单确认 |
|---|---|---|
| ![登录与角色入口](docs/demo-screenshots/01-login-demo-accounts.png) | ![用户首页](docs/demo-screenshots/02-user-home-overview.png) | ![AI 下单确认](docs/demo-screenshots/13-ai-order-proposal-card.png) |

| 骑手配送地图 | 商家菜品管理 | 管理员平台总览 |
|---|---|---|
| ![骑手配送地图](docs/demo-screenshots/30-rider-delivery-map.png) | ![商家菜品管理](docs/demo-screenshots/22-merchant-dishes-filter.png) | ![管理员平台总览](docs/demo-screenshots/32-admin-dashboard-platform.png) |

## 目录结构

```
campus-takeout/
├── backend/      # Spring Boot 后端
├── frontend/     # Vue3 + Vant4 前端
├── uploads/      # 本地图片存储（演示图片）
├── sql/          # init.sql 建库建表 + 演示数据；gen_data.py 数据生成脚本
└── README.md
```

## 启动步骤

### 1. 初始化数据库

```bash
mysql -uroot -proot < sql/init.sql
```

`sql/init.sql` 是从本机 `campus_takeout` 数据库重新导出的完整建库、建表与演示数据文件，包含 9 张表：用户、店铺、菜品、订单、订单明细、地址、评价、分类、公告。

重新导出命令：

```bash
mysqldump -uroot -proot --databases campus_takeout \
  --default-character-set=utf8mb4 \
  --single-transaction --routines --triggers --events \
  --skip-comments --column-statistics=0 --set-gtid-purged=OFF \
  > sql/init.sql
```

> 如数据库账号/密码不同，推荐通过环境变量覆盖：`DB_URL`、`DB_USERNAME`、`DB_PASSWORD`，可参考 `.env.example`。

### 2. 启动后端（端口 8090）

```bash
cd backend
# 需使用 JDK 21
export JAVA_HOME=/path/to/jdk-21
# 可选：配置 AI 助手口令，未配置时基础业务功能仍可运行
export AI_API_PASSWORD=your-ai-api-password
mvn spring-boot:run
```

启动成功后可验证：

```bash
curl -X POST http://localhost:8090/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}'
```

### 3. 启动前端（端口 5175）

```bash
cd frontend
npm install
# 配置高德地图 JSAPI Key 与安全密钥，配送导航需要
export VITE_AMAP_KEY=your-amap-jsapi-key
export VITE_AMAP_SECURITY=your-amap-security-js-code
npm run dev
```

浏览器打开 http://localhost:5175 ，在开发者工具中切换到手机视图（如 iPhone）体验。

## 密钥申请与替换位置

### AI 助手

- 申请入口：讯飞开放平台控制台 https://console.xfyun.cn/
- 接口类型：星火大模型 / OpenAI 兼容 Chat Completions
- 替换位置：后端环境变量 `AI_API_PASSWORD`
- 可选配置：`AI_API_URL`、`AI_MODEL`
- 示例文件：`.env.example`
- 代码读取位置：`backend/src/main/resources/application.yml`

本项目已隐藏真实 AI 口令，开源仓库中不会提交真实 `AI_API_PASSWORD`。未配置 AI 口令时，登录、点餐、订单、商家、骑手、管理员等基础功能仍可运行，AI 对话接口不可用。

前台兜底：如果后端没有配置 `AI_API_PASSWORD`，用户进入「智能助手」页面时会弹出配置框，可直接填写接口地址、口令和模型；配置仅保存在当前浏览器 `localStorage`，不会写入数据库或提交到仓库。

### 高德地图

- 申请入口：高德开放平台控制台 https://console.amap.com/dev/key/app
- 官方准备文档：https://lbs.amap.com/api/javascript-api/guide/abc/prepare
- Key 类型：Web 端 JSAPI Key
- 需要能力：JavaScript API 2.0、路线规划/Driving 插件
- 替换位置：前端环境变量 `VITE_AMAP_KEY`、`VITE_AMAP_SECURITY`
- 示例文件：`.env.example`
- 代码读取位置：`frontend/src/utils/amap.js`

注意：高德 Web 端 JSAPI Key 会在浏览器前端使用，不能像后端密钥一样完全隐藏；建议在高德控制台配置域名白名单和安全密钥，避免直接复用个人生产 Key。

前台兜底：如果没有配置 `VITE_AMAP_KEY` / `VITE_AMAP_SECURITY`，配送地图区域会显示「去申请」和「手动填写」入口；填写后同样只保存在当前浏览器 `localStorage`。

## 演示账号（密码均为 `123456`）

| 角色 | 账号 | 登录后首页 |
|---|---|---|
| 管理员 | `admin` | 平台工作台 |
| 商家 | `merchant1` ~ `merchant15` | 商家工作台 |
| 配送员 | `rider1` ~ `rider5` | 骑手工作台 |
| 用户 | `user1` ~ `user15` | 点餐首页 |

登录页底部可一键填充演示账号。

## 功能清单

### 用户端
- 首页：公告轮播、店铺分类导航、店铺列表、搜索
- 店铺详情：菜品列表、购物车浮层、店铺评价
- 下单：选择收货地址、备注、模拟支付，费用明细（商品 + 包装 + 配送）
- 我的订单：按状态筛选、订单详情与状态跟踪、取消 / 确认收货 / 评价 / 申请退款（已支付未完成可退）
- 配送时效：订单详情展示配送截止时间与实时倒计时（接单后默认 1 小时内送达）；骑手申请延期时显示申请卡片，可同意（时效顺延）或拒绝
- 收货地址管理、个人消费工作台（近 6 月消费折线）
- 智能助手（独立底部 Tab，全屏对话）：推荐美食、解答点餐问题，并支持「聊天即操作」——
  自然语言查询店铺/菜品/地址/订单为只读自动执行；下单购买、评价、退款、取消等写操作助手【只生成确认卡片】，
  须用户在卡片上二次确认后才真正执行，杜绝静默下单/扣款；执行成功后气泡内提供「查看订单」快捷入口

### 商家端
- 工作台：今日/本月营业额、订单数、待接单，近 6 月营业额折线、热销菜品饼图
- 菜品管理：分页、搜索、状态/分类筛选、增改删、上下架、图片上传
- 订单管理：接单（待接单 → 待配送），转交骑手抢单配送
- 评价管理（回复）、店铺设置（含 Logo/封面上传）

### 配送员端
- 骑手工作台：可抢订单数、配送中、今日完成、累计配送收入卡片，近 6 月完成单量柱状图
- 抢单大厅：展示待配送订单（商家已接单），抢单后归属当前骑手（并发抢单有「手慢了」提示）
- 我的配送：配送中 / 已完成分页列表，确认送达，列表显示剩余配送时效
- 配送导航：高德地图展示商家 → 收货地址的配送路线；展示配送时效倒计时，可填写分钟数与原因「申请延期」（待用户审批）

### 管理员端
- 工作台：平台用户/店铺/订单/营收统计，近 6 月营收订单趋势、订单状态分布、店铺分类分布
- 店铺审核管理（通过/驳回/停业/恢复/删除）
- 用户管理（禁用/启用/重置密码/删除）
- 全局订单查询、店铺分类管理、公告管理

## 订单状态流转

```
待支付(1) → 待接单(2) → 待配送(3) → 配送中(4) → 已完成(5)
  用户支付    商家接单    骑手抢单    骑手送达
   ↘ 已取消(6)
```

- 商家接单：`2 → 3`（仅本店订单；接单即开始配送时效计时，截止时间 = 接单时间 + 60 分钟）
- 骑手抢单：`3 → 4`（订单 `rider_id` 置为当前骑手，已被抢的单不可重复抢）
- 骑手送达：`4 → 5`（记录完成时间，配送费计入骑手收入）

### 配送费与配送时效

- 配送费：以下单时店铺配送费为准；免配送费（≤0）的店铺统一按默认 **¥3** 计，保证骑手每单都有配送收入。
- 配送时效：商家接单后开始计时，默认 60 分钟内送达，截止时间（`sla_deadline`）对用户与骑手均可见，前端实时倒计时。
- 申请延期：配送中(4) 时骑手可填写延长分钟数与原因发起申请（`extend_status` 0无 / 1待审批 / 2同意 / 3拒绝）；
  用户在订单详情同意后截止时间顺延对应分钟数，拒绝则时效不变。

## 说明

- 密码使用 MD5 存储，登录通过 JWT 鉴权（请求头 `token`）。
- 智能助手由后端代理调用大模型对话接口（OpenAI 兼容），密钥通过环境变量 `AI_API_PASSWORD` 配置，前端与页面均不暴露密钥。
- 聊天 Agent 采用模型无关的「ReAct + JSON 工具协议」（不依赖厂商 function-calling，任意 OpenAI 兼容模型可驱动）：模型输出工具调用 → 后端执行 → 结果回灌，多轮收敛。
  只读工具（搜索店铺、查菜品、查地址、查订单）自动执行；下单、评价、退款、取消等写操作助手【不直接执行】，只生成「待确认提案（proposal）」回传前端，由用户在卡片上二次确认后，前端再调用对应业务接口真正执行——杜绝模型静默下单/扣款。
  所有写操作一律以服务端登录态 `userId` 执行，绝不信任模型传入的用户身份；下单/退款受起送价、订单状态、归属等业务校验约束。
- 演示数据时间分布在近 6 个月，便于按月统计图表展示。
- 配送路线由高德地图 JSAPI 绘制（商家与收货地址坐标按订单 ID 在校园中心附近确定性生成），仅地图瓦片需联网，属功能性地图服务。
- 除地图外，所有静态资源（Vant、ECharts、图片）均本地化，无外部 CDN/图床/在线字体依赖。
