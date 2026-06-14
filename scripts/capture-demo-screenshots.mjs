import fs from 'node:fs/promises';
import path from 'node:path';
import { createRequire } from 'node:module';

const root = path.resolve(import.meta.dirname, '..');
const require = createRequire(import.meta.url);
const { chromium } = require(path.join(root, 'demo-video/node_modules/playwright'));
const outDir = path.join(root, 'docs/demo-screenshots');
const baseUrl = process.env.DEMO_BASE_URL || 'http://localhost:5175';
const apiBase = process.env.DEMO_API_BASE || 'http://localhost:8090/api';

const viewport = { width: 390, height: 844 };

const accounts = {
  user: { username: 'user1', password: '123456' },
  merchant: { username: 'merchant1', password: '123456' },
  admin: { username: 'admin', password: '123456' },
  rider: { username: 'rider1', password: '123456' }
};

const aiReplies = [
  {
    match: '奶茶',
    data: {
      reply: '我找到校园里销量较高的奶茶店：CoCo都可奶茶和一点点奶茶。已按真实店铺和菜品数据为你准备好下单卡片，写操作需要你二次确认。',
      actions: [],
      proposal: {
        type: 'place_order',
        title: '确认下单并支付',
        summary: 'CoCo都可奶茶\n珍珠奶茶 x2\n默认地址：XX大学桃园宿舍277室\n预计实付 ¥33.60',
        payload: {
          shopId: 10,
          addressId: 1,
          remark: 'AI助手推荐',
          items: [{ dishId: 73, quantity: 2 }]
        }
      }
    }
  },
  {
    match: '最近',
    data: {
      reply: '这是你最近的订单：CoCo都可奶茶，订单号 202606131730298750，状态为待接单，实付 ¥33.60。可以继续查看订单详情或发起售后。',
      actions: [{ orderId: 85, orderNo: '202606131730298750' }]
    }
  },
  {
    match: '评价',
    data: {
      reply: '已找到你最近完成的订单：黄焖鸡米饭旗舰店。评价属于写操作，我已准备好确认卡片，确认后才会提交。',
      actions: [],
      proposal: {
        type: 'review_order',
        title: '确认提交评价',
        summary: '黄焖鸡米饭旗舰店\n评分：5星\n内容：味道不错，配送及时，下次还会点。',
        payload: {
          orderId: 62,
          rating: 5,
          content: '味道不错，配送及时，下次还会点。'
        }
      }
    }
  },
  {
    match: '退款',
    data: {
      reply: '订单退款需要你确认后执行。我已为最近待接单订单生成退款确认卡片，确认前不会改变订单状态。',
      actions: [],
      proposal: {
        type: 'refund_order',
        title: '确认申请退款',
        summary: 'CoCo都可奶茶\n订单号：202606131730298750\n申请退款金额：¥33.60',
        payload: {
          orderId: 85,
          orderNo: '202606131730298750'
        }
      }
    }
  }
];

async function login(username, password) {
  const res = await fetch(`${apiBase}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password })
  });
  const json = await res.json();
  if (json.code !== 200) throw new Error(`Login failed for ${username}: ${json.message}`);
  return json.data;
}

async function setLogin(page, account) {
  const data = await login(account.username, account.password);
  await page.addInitScript(({ token, user }) => {
    localStorage.setItem('token', token);
    localStorage.setItem('user', JSON.stringify(user));
  }, data);
  await page.evaluate(({ token, user }) => {
    localStorage.setItem('token', token);
    localStorage.setItem('user', JSON.stringify(user));
  }, data).catch(() => {});
}

async function settle(page) {
  await page.waitForLoadState('domcontentloaded');
  await page.waitForTimeout(900);
}

async function shot(page, index, slug, title, opts = {}) {
  if (opts.scrollTo != null) {
    await page.evaluate((y) => window.scrollTo(0, y), opts.scrollTo);
    await page.waitForTimeout(400);
  }
  const file = `${String(index).padStart(2, '0')}-${slug}.png`;
  await page.screenshot({ path: path.join(outDir, file), fullPage: false });
  return { index, slug, title, file: `docs/demo-screenshots/${file}` };
}

async function goto(page, url) {
  await page.goto(`${baseUrl}${url}`);
  await settle(page);
}

async function clickText(page, text) {
  const loc = page.getByText(text, { exact: false });
  await loc.first().click();
  await page.waitForTimeout(600);
}

async function run() {
  await fs.rm(outDir, { recursive: true, force: true });
  await fs.mkdir(outDir, { recursive: true });

  const browser = await chromium.launch({
    headless: true,
    executablePath: process.env.CHROME_PATH || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
  });
  const context = await browser.newContext({
    viewport,
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
    locale: 'zh-CN'
  });

  await context.route('**/api/ai/agent', async (route) => {
    const body = route.request().postDataJSON();
    const last = [...(body.messages || [])].reverse().find((m) => m.role === 'user')?.content || '';
    const hit = aiReplies.find((r) => last.includes(r.match)) || aiReplies[0];
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ code: 200, message: 'success', data: hit.data })
    });
  });

  const page = await context.newPage();
  const meta = [];
  let i = 1;

  await goto(page, '/login');
  meta.push(await shot(page, i++, 'login-demo-accounts', '登录页与四类演示账号'));

  await setLogin(page, accounts.user);
  await goto(page, '/home');
  meta.push(await shot(page, i++, 'user-home-overview', '用户首页：公告、分类、店铺列表'));
  await page.evaluate(() => window.scrollTo(0, 420));
  await page.waitForTimeout(400);
  meta.push(await shot(page, i++, 'user-home-shop-list', '用户首页：店铺列表与销量评分'));

  await goto(page, '/shop/10');
  meta.push(await shot(page, i++, 'shop-detail-coco-dishes', '店铺详情：CoCo都可奶茶菜品'));
  await page.locator('.dish-item .add').first().click();
  await page.waitForTimeout(300);
  await page.locator('.dish-item .add').first().click();
  await page.waitForTimeout(300);
  meta.push(await shot(page, i++, 'shop-cart-selected', '点餐购物车：已选择商品'));
  await page.locator('.cart-left').click();
  await page.waitForTimeout(400);
  meta.push(await shot(page, i++, 'shop-cart-popup', '购物车浮层：商品数量与金额'));
  await page.keyboard.press('Escape').catch(() => {});
  await page.locator('.van-overlay').click({ trial: true }).catch(() => {});
  await goto(page, '/confirm');
  meta.push(await shot(page, i++, 'order-confirm-fees', '订单确认：地址、备注、费用明细'));
  await goto(page, '/orders');
  meta.push(await shot(page, i++, 'user-orders-status-tabs', '我的订单：状态筛选与操作按钮'));
  await goto(page, '/order/85');
  meta.push(await shot(page, i++, 'order-detail-tracking', '订单详情：状态跟踪与商品明细'));
  await page.evaluate(() => window.scrollTo(0, 480));
  await page.waitForTimeout(400);
  meta.push(await shot(page, i++, 'order-detail-fees-sla', '订单详情：费用、订单号与售后入口'));

  await goto(page, '/assistant');
  meta.push(await shot(page, i++, 'ai-assistant-empty', '智能助手：全屏对话入口'));
  await page.getByText('帮我推荐并买一杯奶茶').click();
  meta.push(await shot(page, i++, 'ai-assistant-quick-order', '智能助手：快捷指令填入下单需求'));
  await page.getByRole('button', { name: '发送' }).click();
  await page.waitForTimeout(800);
  meta.push(await shot(page, i++, 'ai-order-proposal-card', 'AI下单：推荐真实店铺并生成确认卡片'));
  await page.getByText('我最近的订单').click();
  await page.getByRole('button', { name: '发送' }).click();
  await page.waitForTimeout(800);
  meta.push(await shot(page, i++, 'ai-order-query-action', 'AI查询：最近订单与查看入口'));
  await page.getByText('给最近完成的订单评价5星').click();
  await page.getByRole('button', { name: '发送' }).click();
  await page.waitForTimeout(800);
  meta.push(await shot(page, i++, 'ai-review-proposal-card', 'AI评价：写操作二次确认'));
  await page.getByText('帮我退款最近的订单').click();
  await page.getByRole('button', { name: '发送' }).click();
  await page.waitForTimeout(800);
  meta.push(await shot(page, i++, 'ai-refund-proposal-card', 'AI退款：确认前不改变订单状态'));

  await goto(page, '/address');
  meta.push(await shot(page, i++, 'user-address-list', '收货地址管理'));
  await goto(page, '/user-dashboard');
  meta.push(await shot(page, i++, 'user-dashboard-stats', '用户消费工作台：近六月消费趋势'));
  await goto(page, '/mine');
  meta.push(await shot(page, i++, 'user-profile-center', '我的：账号、工作台、地址入口'));

  await context.clearCookies();
  await page.evaluate(() => localStorage.clear()).catch(() => {});
  await setLogin(page, accounts.merchant);
  await goto(page, '/m/dashboard');
  meta.push(await shot(page, i++, 'merchant-dashboard-stats', '商家工作台：营收和订单统计'));
  await page.evaluate(() => window.scrollTo(0, 420));
  await page.waitForTimeout(400);
  meta.push(await shot(page, i++, 'merchant-dashboard-charts', '商家工作台：营业额与热销菜品图表'));
  await goto(page, '/m/dishes');
  meta.push(await shot(page, i++, 'merchant-dishes-filter', '菜品管理：分页、搜索、筛选'));
  await page.locator('.fab').click();
  await page.waitForTimeout(500);
  meta.push(await shot(page, i++, 'merchant-dish-edit-dialog', '菜品管理：新增菜品与图片上传'));
  await page.keyboard.press('Escape').catch(() => {});
  await goto(page, '/m/orders');
  meta.push(await shot(page, i++, 'merchant-orders-accept', '商家订单：待接单与接单处理'));
  await goto(page, '/m/reviews');
  meta.push(await shot(page, i++, 'merchant-review-reply', '评价管理：商家回复用户评价'));
  await goto(page, '/m/shop');
  meta.push(await shot(page, i++, 'merchant-shop-setting', '店铺设置：封面、Logo、营业参数'));

  await context.clearCookies();
  await page.evaluate(() => localStorage.clear()).catch(() => {});
  await setLogin(page, accounts.rider);
  await goto(page, '/r/dashboard');
  meta.push(await shot(page, i++, 'rider-dashboard-stats', '骑手工作台：可抢单与配送收入'));
  await goto(page, '/r/hall');
  meta.push(await shot(page, i++, 'rider-order-hall', '抢单大厅：待配送订单'));
  await goto(page, '/r/orders');
  meta.push(await shot(page, i++, 'rider-my-deliveries', '我的配送：配送中与已完成'));
  await goto(page, '/r/order/69');
  meta.push(await shot(page, i++, 'rider-delivery-map', '配送导航：地图路线与配送状态'));
  await page.evaluate(() => window.scrollTo(0, 520));
  await page.waitForTimeout(400);
  meta.push(await shot(page, i++, 'rider-extend-request', '配送时效：骑手申请延期'));

  await context.clearCookies();
  await page.evaluate(() => localStorage.clear()).catch(() => {});
  await setLogin(page, accounts.admin);
  await goto(page, '/a/dashboard');
  meta.push(await shot(page, i++, 'admin-dashboard-platform', '管理员工作台：平台核心指标'));
  await page.evaluate(() => window.scrollTo(0, 430));
  await page.waitForTimeout(400);
  meta.push(await shot(page, i++, 'admin-dashboard-charts', '管理员工作台：营收订单与分布图'));
  await goto(page, '/a/shops');
  meta.push(await shot(page, i++, 'admin-shop-audit', '店铺审核：通过、驳回、停业'));
  await goto(page, '/a/orders');
  meta.push(await shot(page, i++, 'admin-order-global-query', '全局订单：状态搜索与分页'));
  await goto(page, '/a/users');
  meta.push(await shot(page, i++, 'admin-user-management', '用户管理：禁用、重置密码、删除'));
  await goto(page, '/a/categories');
  meta.push(await shot(page, i++, 'admin-category-management', '分类管理：图标与排序维护'));
  await goto(page, '/a/notices');
  meta.push(await shot(page, i++, 'admin-notice-management', '公告管理：首页公告维护'));

  await fs.writeFile(
    path.join(root, 'docs/demo-screenshots/screenshots.json'),
    JSON.stringify(meta, null, 2)
  );
  await browser.close();
  console.log(`Captured ${meta.length} screenshots in ${outDir}`);
}

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
