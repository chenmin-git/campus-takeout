# -*- coding: utf-8 -*-
"""
演示数据与本地图片生成器。
- 生成食品主题 SVG 图片到 uploads/（分类图标、店铺logo/封面、菜品图、头像），全部本地相对路径。
- 同步生成 sql/init.sql（建表 + 演示数据），图片字段写入对应相对路径。
密码统一存 md5("123456")。
"""
import os
import hashlib
import random
from datetime import datetime, timedelta

random.seed(20260613)

BASE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(BASE)
UP = os.path.join(PROJECT, "uploads")

for sub in ["category", "shop", "dish", "avatar"]:
    os.makedirs(os.path.join(UP, sub), exist_ok=True)

MD5_123456 = hashlib.md5("123456".encode()).hexdigest()

# ---------- SVG 生成 ----------
GRADS = [
    ("#FF7E5F", "#FEB47B"), ("#43C6AC", "#191654"), ("#FFB75E", "#ED8F03"),
    ("#56AB2F", "#A8E063"), ("#614385", "#516395"), ("#F857A6", "#FF5858"),
    ("#36D1DC", "#5B86E5"), ("#F2994A", "#F2C94C"), ("#11998E", "#38EF7D"),
    ("#FC5C7D", "#6A82FB"), ("#F09819", "#EDDE5D"), ("#EB3349", "#F45C43"),
]

def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

def write_svg(path, content):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

def food_glyph(kind, cx, cy, r):
    """根据品类画一个简单的白色食物图形"""
    if kind == "drink":  # 杯子
        return (f'<rect x="{cx-r*0.45}" y="{cy-r*0.6}" width="{r*0.9}" height="{r*1.2}" rx="{r*0.12}" fill="#fff" opacity="0.95"/>'
                f'<rect x="{cx-r*0.45}" y="{cy-r*0.6}" width="{r*0.9}" height="{r*0.22}" fill="#fff"/>'
                f'<line x1="{cx+r*0.1}" y1="{cy-r*0.9}" x2="{cx+r*0.3}" y2="{cy-r*0.4}" stroke="#fff" stroke-width="{r*0.08}" stroke-linecap="round"/>')
    if kind == "bowl":  # 碗/米饭
        return (f'<path d="M {cx-r*0.6} {cy-r*0.1} A {r*0.6} {r*0.6} 0 0 0 {cx+r*0.6} {cy-r*0.1} Z" fill="#fff" opacity="0.95"/>'
                f'<ellipse cx="{cx}" cy="{cy-r*0.1}" rx="{r*0.6}" ry="{r*0.16}" fill="#fff"/>'
                f'<ellipse cx="{cx}" cy="{cy-r*0.16}" rx="{r*0.5}" ry="{r*0.13}" fill="#FFE9C7"/>')
    if kind == "burger":  # 汉堡/快餐
        return (f'<path d="M {cx-r*0.55} {cy-r*0.25} A {r*0.55} {r*0.45} 0 0 1 {cx+r*0.55} {cy-r*0.25} Z" fill="#fff"/>'
                f'<rect x="{cx-r*0.55}" y="{cy-r*0.15}" width="{r*1.1}" height="{r*0.18}" fill="#FFD27F"/>'
                f'<rect x="{cx-r*0.55}" y="{cy+r*0.05}" width="{r*1.1}" height="{r*0.22}" rx="{r*0.1}" fill="#fff"/>')
    if kind == "noodle":  # 面
        return (f'<path d="M {cx-r*0.55} {cy-r*0.05} A {r*0.55} {r*0.55} 0 0 0 {cx+r*0.55} {cy-r*0.05} Z" fill="#fff" opacity="0.95"/>'
                f'<path d="M {cx-r*0.4} {cy-r*0.05} q {r*0.1} {-r*0.5} {r*0.2} 0 q {r*0.1} {-r*0.5} {r*0.2} 0 q {r*0.1} {-r*0.5} {r*0.2} 0" stroke="#FFE9C7" stroke-width="{r*0.07}" fill="none"/>')
    if kind == "cake":  # 甜品
        return (f'<rect x="{cx-r*0.45}" y="{cy-r*0.1}" width="{r*0.9}" height="{r*0.55}" rx="{r*0.08}" fill="#fff"/>'
                f'<path d="M {cx-r*0.45} {cy-r*0.1} L {cx} {cy-r*0.55} L {cx+r*0.45} {cy-r*0.1} Z" fill="#fff" opacity="0.9"/>'
                f'<circle cx="{cx}" cy="{cy-r*0.55}" r="{r*0.08}" fill="#FF5858"/>')
    if kind == "salad":  # 沙拉/轻食
        return (f'<path d="M {cx-r*0.6} {cy-r*0.05} A {r*0.6} {r*0.6} 0 0 0 {cx+r*0.6} {cy-r*0.05} Z" fill="#fff" opacity="0.95"/>'
                f'<circle cx="{cx-r*0.2}" cy="{cy-r*0.12}" r="{r*0.14}" fill="#7BC47F"/>'
                f'<circle cx="{cx+r*0.15}" cy="{cy-r*0.18}" r="{r*0.12}" fill="#F2C94C"/>'
                f'<circle cx="{cx+r*0.05}" cy="{cy-r*0.02}" r="{r*0.1}" fill="#FF8A65"/>')
    # default 烧烤
    return (f'<rect x="{cx-r*0.5}" y="{cy-r*0.12}" width="{r}" height="{r*0.16}" rx="{r*0.08}" fill="#fff"/>'
            f'<circle cx="{cx-r*0.25}" cy="{cy-r*0.04}" r="{r*0.13}" fill="#F2994A"/>'
            f'<circle cx="{cx+r*0.05}" cy="{cy-r*0.04}" r="{r*0.13}" fill="#EB5757"/>'
            f'<circle cx="{cx+r*0.32}" cy="{cy-r*0.04}" r="{r*0.13}" fill="#F2C94C"/>'
            f'<line x1="{cx-r*0.55}" y1="{cy-r*0.04}" x2="{cx+r*0.6}" y2="{cy-r*0.04}" stroke="#A0522D" stroke-width="{r*0.05}"/>')

def gen_card(path, title, kind, grad, w=600, h=600):
    c1, c2 = grad
    gid = "g" + str(abs(hash(path)) % 100000)
    title = esc(title)
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
<defs><linearGradient id="{gid}" x1="0" y1="0" x2="1" y2="1">
<stop offset="0" stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></linearGradient></defs>
<rect width="{w}" height="{h}" fill="url(#{gid})"/>
<circle cx="{w/2}" cy="{h*0.42}" r="{w*0.26}" fill="#ffffff" opacity="0.18"/>
{food_glyph(kind, w/2, h*0.42, w*0.26)}
<text x="{w/2}" y="{h*0.86}" font-size="{w*0.085}" fill="#ffffff" text-anchor="middle" font-family="PingFang SC, Microsoft YaHei, sans-serif" font-weight="bold">{title}</text>
</svg>'''
    write_svg(path, svg)

def gen_icon(path, ch, grad, size=120):
    c1, c2 = grad
    gid = "i" + str(abs(hash(path)) % 100000)
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 {size} {size}">
<defs><linearGradient id="{gid}" x1="0" y1="0" x2="1" y2="1">
<stop offset="0" stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></linearGradient></defs>
<rect width="{size}" height="{size}" rx="{size*0.28}" fill="url(#{gid})"/>
<text x="{size/2}" y="{size*0.64}" font-size="{size*0.46}" fill="#fff" text-anchor="middle" font-family="PingFang SC, Microsoft YaHei, sans-serif" font-weight="bold">{esc(ch)}</text>
</svg>'''
    write_svg(path, svg)

# ---------- 业务数据定义 ----------
# 店铺分类：(名称, 品类glyph)
categories = [
    ("快餐简餐", "burger"), ("奶茶饮品", "drink"), ("米饭套餐", "bowl"),
    ("面食粉面", "noodle"), ("烧烤夜宵", "bbq"), ("甜品烘焙", "cake"),
    ("营养早餐", "bowl"), ("轻食沙拉", "salad"),
]

# 每个分类的菜品名池
dish_pool = {
    "快餐简餐": ["香辣鸡腿堡", "黄金鸡块", "薯条(大)", "劲脆鸡排饭", "照烧鸡腿堡", "可乐鸡翅", "牛肉汉堡", "原味炸鸡"],
    "奶茶饮品": ["珍珠奶茶", "杨枝甘露", "芝芝莓莓", "百香果茶", "招牌奶绿", "黑糖波波", "柠檬蜂蜜茶", "椰果奶茶"],
    "米饭套餐": ["黄焖鸡米饭", "宫保鸡丁饭", "红烧肉盖饭", "土豆牛肉饭", "鱼香肉丝饭", "排骨饭", "麻婆豆腐饭", "咖喱鸡饭"],
    "面食粉面": ["牛肉拉面", "酸辣粉", "重庆小面", "番茄鸡蛋面", "螺蛳粉", "炸酱面", "热干面", "鸭血粉丝汤"],
    "烧烤夜宵": ["烤羊肉串(10串)", "烤鸡翅", "烤韭菜", "烤金针菇", "烤茄子", "烤五花肉", "烤玉米", "麻辣小龙虾"],
    "甜品烘焙": ["提拉米苏", "芒果千层", "草莓蛋糕", "巧克力慕斯", "蛋挞(2个)", "双皮奶", "舒芙蕾", "红豆双皮奶"],
    "营养早餐": ["皮蛋瘦肉粥", "小笼包(6个)", "豆浆油条", "鲜肉包", "蒸饺(8个)", "煎蛋三明治", "南瓜粥", "手抓饼"],
    "轻食沙拉": ["鸡胸肉沙拉", "牛油果沙拉", "藜麦缤纷沙拉", "金枪鱼沙拉", "水果酸奶碗", "全麦鸡蛋卷", "缤纷蔬菜杯", "低脂能量碗"],
}

# 店铺定义：(店名, 分类索引, 状态)  状态:0待审核 1营业 2停业 3驳回
shops_def = [
    ("张亮汉堡快餐店", 0, 1), ("一点点奶茶(南门店)", 1, 1), ("黄焖鸡米饭旗舰店", 2, 1),
    ("兰州牛肉拉面馆", 3, 1), ("深夜食堂烧烤", 4, 1), ("甜心烘焙坊", 5, 1),
    ("元气营养早餐铺", 6, 1), ("轻享健康轻食", 7, 1), ("汉堡王(东区店)", 0, 1),
    ("CoCo都可奶茶", 1, 1), ("老碗面食馆", 3, 1), ("校园风味烧烤摊", 4, 1),
    ("待审核·新晋茶饮店", 1, 0), ("待审核·麻辣香锅快餐", 0, 0), ("被驳回·三无小吃铺", 4, 3),
]

shop_address = ["第一食堂一楼", "南门美食街12号", "东区商业街", "学生公寓3栋底商", "图书馆负一层", "西门小吃街",
                "北苑食堂二楼", "体育馆旁商铺", "桃园餐厅", "梅园美食广场", "竹园小吃城", "听涛苑底商",
                "新晋创业园", "美食街待租位", "已下架"]

notice_pool = ["满30减5，欢迎下单！", "本店新品上线，敬请品尝~", "下雨天配送可能延迟，请耐心等待", "招牌套餐买一送一",
               "营业时间 9:00-22:00", "支持线上点单，到店自取", "会员专享 9 折优惠", "夜宵时段加量不加价"]

avatar_palette = GRADS

# ---------- 生成图片 ----------
# 分类图标
cat_icons = []
for i, (cname, _) in enumerate(categories):
    fn = f"category/cat_{i+1}.svg"
    gen_icon(os.path.join(UP, fn), cname[0], GRADS[i % len(GRADS)])
    cat_icons.append("uploads/" + fn)

# 店铺 logo + 封面
shop_logos, shop_covers = [], []
for i, (sname, cidx, _) in enumerate(shops_def):
    g = GRADS[(cidx + i) % len(GRADS)]
    logo_fn = f"shop/logo_{i+1}.svg"
    cover_fn = f"shop/cover_{i+1}.svg"
    gen_icon(os.path.join(UP, logo_fn), sname[0], g, size=200)
    gen_card(os.path.join(UP, cover_fn), sname, categories[cidx][1], g, w=800, h=400)
    shop_logos.append("uploads/" + logo_fn)
    shop_covers.append("uploads/" + cover_fn)

# 菜品图（按分类下每个菜名生成）
dish_img = {}  # (cat_name, dish_name) -> path
for ci, (cname, glyph) in enumerate(categories):
    for di, dname in enumerate(dish_pool[cname]):
        fn = f"dish/d_{ci+1}_{di+1}.svg"
        gen_card(os.path.join(UP, fn), dname, glyph, GRADS[(ci + di) % len(GRADS)])
        dish_img[(cname, dname)] = "uploads/" + fn

# 头像
avatars = []
for i in range(10):
    fn = f"avatar/a_{i+1}.svg"
    gen_icon(os.path.join(UP, fn), "用", avatar_palette[i % len(avatar_palette)], size=120)
    avatars.append("uploads/" + fn)

# ---------- 生成用户 ----------
def dt(d):
    return d.strftime("%Y-%m-%d %H:%M:%S")

NOW = datetime(2026, 6, 13, 12, 0, 0)
def rand_time(days_back_max=180):
    d = NOW - timedelta(days=random.randint(1, days_back_max),
                        hours=random.randint(0, 23), minutes=random.randint(0, 59))
    return d

users = []  # (id, username, nickname, role, phone, avatar, status, create_time)
uid = 1
# 管理员
users.append((uid, "admin", "系统管理员", "ADMIN", "13800000000", avatars[0], 1, dt(datetime(2025,12,1,9,0,0)))); uid += 1
# 商家（每个店铺一个 owner）
merchant_ids = []
merchant_names = ["张亮", "一点点", "黄记老板", "马师傅", "烧烤老王", "甜心姐", "早餐铺老板", "轻食店主",
                  "汉堡王店长", "CoCo店长", "面馆老李", "烧烤小哥", "新茶饮老板", "香锅老板", "小吃铺主"]
for i, mn in enumerate(merchant_names):
    users.append((uid, f"merchant{i+1}", mn, "MERCHANT", f"139000000{i:02d}", avatars[i % len(avatars)], 1, dt(rand_time(170))))
    merchant_ids.append(uid); uid += 1
# 普通用户
normal_names = ["小明", "小红", "李雷", "韩梅梅", "王小二", "赵四", "刘能", "谢广坤", "宋小宝", "周杰",
                "陈乔恩", "林志玲", "黄渤", "徐峥", "沈腾"]
normal_ids = []
for i, nn in enumerate(normal_names):
    users.append((uid, f"user{i+1}", nn, "USER", f"137000000{i:02d}", avatars[i % len(avatars)], 1, dt(rand_time(160))))
    normal_ids.append(uid); uid += 1

# ---------- 店铺 ----------
shops = []  # id, name, logo, cover, desc, cat_id, owner, addr, notice, deliveryFee, minAmount, rating, sales, status, create
for i, (sname, cidx, status) in enumerate(shops_def):
    sid = i + 1
    rating = round(random.uniform(4.0, 4.9), 1) if status == 1 else round(random.uniform(3.5, 4.5), 1)
    sales = random.randint(120, 3200) if status == 1 else random.randint(0, 50)
    deliv = random.choice([0, 1, 2, 3, 5])
    minamt = random.choice([15, 20, 20, 25, 30])
    shops.append((sid, sname, shop_logos[i], shop_covers[i],
                  f"{sname}，主营{categories[cidx][0]}，校园人气好店。", cidx + 1, merchant_ids[i],
                  shop_address[i], random.choice(notice_pool), deliv, minamt, rating, sales, status,
                  dt(rand_time(165))))

# ---------- 菜品 ----------
dishes = []  # id, shopId, name, image, price, desc, dishCat, sales, stock, status, create
did = 1
shop_dishes = {}  # shopId -> list of (did, price, name, image)
for i, (sname, cidx, status) in enumerate(shops_def):
    sid = i + 1
    cname = categories[cidx][0]
    pool = dish_pool[cname]
    n = random.randint(6, 8)
    chosen = pool[:n]
    shop_dishes[sid] = []
    for dname in chosen:
        price = round(random.uniform(8, 38), 1)
        dsales = random.randint(0, 800)
        img = dish_img[(cname, dname)]
        dishes.append((did, sid, dname, img, price, f"{dname}，{sname}招牌出品", cname,
                       dsales, random.randint(20, 200), 1, dt(rand_time(150))))
        shop_dishes[sid].append((did, price, dname, img))
        did += 1

# ---------- 地址 ----------
addresses = []  # id, userId, name, phone, detail, isDefault
aid = 1
campus_places = ["第一教学楼", "图书馆", "学生公寓1栋", "学生公寓5栋", "梅园宿舍", "桃园宿舍", "体育馆", "实验楼", "行政楼", "南门"]
for u in users:
    if u[3] != "USER":
        continue
    cnt = random.randint(1, 2)
    for k in range(cnt):
        addresses.append((aid, u[0], u[2], u[4], f"XX大学{random.choice(campus_places)}{random.randint(101,520)}室",
                          1 if k == 0 else 0))
        aid += 1

# ---------- 订单 + 明细 ----------
orders = []  # id, orderNo, userId, shopId, goods, pack, deliv, total, status, addrSnap, remark, create, pay, finish
order_items = []  # id, orderId, dishId, name, image, price, qty
reviews = []  # id, orderId, userId, shopId, rating, content, images, reply, create
oid = 1
oiid = 1
rid = 1
open_shops = [s for s in shops if s[13] == 1]
review_texts = ["味道不错，分量足，下次还来！", "送餐很快，包装也好", "性价比很高，推荐", "口味一般，可以接受",
                "非常好吃，已经回购啦", "配送有点慢，味道还行", "包装精致，味道惊艳", "学生党福音，便宜量大"]
reply_texts = ["感谢支持，欢迎再次光临！", "谢谢您的好评，我们会继续努力~", "感谢反馈，我们会改进配送速度"]
status_pool = [2, 3, 4, 5, 5, 5, 5, 6]  # 偏向已完成
remark_pool = ["不要辣", "多加一份米饭", "送到宿舍楼下", "不要香菜", "餐具一份", "尽快配送", "少冰", ""]

for _ in range(72):
    shop = random.choice(open_shops)
    sid = shop[0]
    if not shop_dishes.get(sid):
        continue
    uid_o = random.choice(normal_ids)
    ctime = rand_time(180)
    status = random.choice(status_pool)
    item_n = random.randint(1, 4)
    picks = random.sample(shop_dishes[sid], min(item_n, len(shop_dishes[sid])))
    goods = 0
    items_tmp = []
    for (pdid, pprice, pname, pimg) in picks:
        qty = random.randint(1, 3)
        goods += pprice * qty
        items_tmp.append((pdid, pname, pimg, pprice, qty))
    goods = round(goods, 1)
    pack = 1.0
    deliv = float(shop[9])
    total = round(goods + pack + deliv, 1)
    addr = f"XX大学{random.choice(campus_places)}{random.randint(101,520)}室"
    pay_time = dt(ctime + timedelta(minutes=random.randint(1, 5))) if status != 1 else "NULL"
    finish_time = dt(ctime + timedelta(minutes=random.randint(30, 80))) if status == 5 else "NULL"
    orderno = ctime.strftime("%Y%m%d%H%M%S") + str(random.randint(1000, 9999))
    orders.append((oid, orderno, uid_o, sid, goods, pack, deliv, total, status, addr,
                   random.choice(remark_pool), dt(ctime), pay_time, finish_time))
    for (pdid, pname, pimg, pprice, qty) in items_tmp:
        order_items.append((oiid, oid, pdid, pname, pimg, pprice, qty))
        oiid += 1
    # 已完成订单约 60% 生成评价
    if status == 5 and random.random() < 0.6:
        reviews.append((rid, oid, uid_o, sid, random.randint(3, 5), random.choice(review_texts),
                        "", random.choice(reply_texts) if random.random() < 0.5 else "",
                        dt(ctime + timedelta(hours=random.randint(2, 48)))))
        rid += 1
    oid += 1

# 重新计算店铺评分/销量统计可在前端做，这里用现成字段

notices_data = [
    ("平台上线公告", "校园外卖平台正式上线，欢迎广大师生使用，足不出户享受美食！"),
    ("配送时间调整", "因近期天气原因，部分时段配送时间延长，请大家耐心等待。"),
    ("新商家入驻", "本周新增多家优质商户，更多美味等你来发现。"),
    ("评价有奖活动", "完成订单并评价，即有机会获得平台优惠券。"),
    ("文明用餐倡议", "请大家节约粮食，按需点餐，共建文明校园。"),
    ("客服服务时间", "平台客服服务时间为每日 8:00-22:00，如有问题请及时反馈。"),
]

# ---------- 输出 SQL ----------
def s(v):
    if v is None:
        return "NULL"
    if isinstance(v, str):
        if v == "NULL":
            return "NULL"
        return "'" + v.replace("'", "''") + "'"
    return str(v)

lines = []
lines.append("-- 校园外卖系统 建库建表 + 演示数据（自动生成）")
lines.append("SET NAMES utf8mb4;")
lines.append("DROP DATABASE IF EXISTS campus_takeout;")
lines.append("CREATE DATABASE campus_takeout DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;")
lines.append("USE campus_takeout;")
lines.append("")

schema = """
CREATE TABLE user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL UNIQUE COMMENT '登录账号',
  password VARCHAR(64) NOT NULL COMMENT 'md5密码',
  nickname VARCHAR(50) COMMENT '昵称',
  avatar VARCHAR(255) COMMENT '头像相对路径',
  phone VARCHAR(20),
  role VARCHAR(20) NOT NULL COMMENT 'USER/MERCHANT/ADMIN',
  status TINYINT DEFAULT 1 COMMENT '1正常0禁用',
  create_time DATETIME,
  deleted TINYINT DEFAULT 0
) COMMENT '用户表';

CREATE TABLE shop_category (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  icon VARCHAR(255),
  sort INT DEFAULT 0
) COMMENT '店铺分类';

CREATE TABLE shop (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  logo VARCHAR(255),
  cover VARCHAR(255),
  description VARCHAR(255),
  category_id BIGINT,
  owner_id BIGINT COMMENT '商家用户id',
  address VARCHAR(255),
  notice VARCHAR(255),
  delivery_fee DECIMAL(10,2) DEFAULT 0,
  min_amount DECIMAL(10,2) DEFAULT 0,
  rating DECIMAL(2,1) DEFAULT 5.0,
  sales INT DEFAULT 0,
  status TINYINT DEFAULT 0 COMMENT '0待审核1营业2停业3驳回',
  create_time DATETIME,
  deleted TINYINT DEFAULT 0
) COMMENT '店铺';

CREATE TABLE dish (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  shop_id BIGINT NOT NULL,
  name VARCHAR(100) NOT NULL,
  image VARCHAR(255),
  price DECIMAL(10,2) NOT NULL,
  description VARCHAR(255),
  dish_category VARCHAR(50),
  sales INT DEFAULT 0,
  stock INT DEFAULT 0,
  status TINYINT DEFAULT 1 COMMENT '1上架0下架',
  create_time DATETIME,
  deleted TINYINT DEFAULT 0
) COMMENT '菜品';

CREATE TABLE address (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  name VARCHAR(50),
  phone VARCHAR(20),
  detail VARCHAR(255),
  is_default TINYINT DEFAULT 0,
  deleted TINYINT DEFAULT 0
) COMMENT '收货地址';

CREATE TABLE orders (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_no VARCHAR(40) NOT NULL,
  user_id BIGINT NOT NULL,
  shop_id BIGINT NOT NULL,
  goods_amount DECIMAL(10,2),
  pack_fee DECIMAL(10,2),
  delivery_fee DECIMAL(10,2),
  total_amount DECIMAL(10,2),
  status TINYINT COMMENT '1待支付2待接单3待配送4配送中5已完成6已取消',
  address_snapshot VARCHAR(255),
  remark VARCHAR(255),
  create_time DATETIME,
  pay_time DATETIME,
  finish_time DATETIME,
  deleted TINYINT DEFAULT 0
) COMMENT '订单';

CREATE TABLE order_item (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_id BIGINT NOT NULL,
  dish_id BIGINT,
  dish_name VARCHAR(100),
  dish_image VARCHAR(255),
  price DECIMAL(10,2),
  quantity INT
) COMMENT '订单明细';

CREATE TABLE review (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_id BIGINT,
  user_id BIGINT,
  shop_id BIGINT,
  rating TINYINT,
  content VARCHAR(500),
  images VARCHAR(1000),
  reply VARCHAR(500),
  create_time DATETIME,
  deleted TINYINT DEFAULT 0
) COMMENT '评价';

CREATE TABLE notice (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(100),
  content VARCHAR(500),
  create_time DATETIME,
  deleted TINYINT DEFAULT 0
) COMMENT '公告';
"""
lines.append(schema)

# 分类
lines.append("-- 店铺分类")
for i, (cname, _) in enumerate(categories):
    lines.append(f"INSERT INTO shop_category(id,name,icon,sort) VALUES ({i+1},{s(cname)},{s(cat_icons[i])},{i});")
lines.append("")

# 用户
lines.append("-- 用户")
for u in users:
    lines.append("INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES "
                 f"({u[0]},{s(u[1])},{s(MD5_123456)},{s(u[2])},{s(u[5])},{s(u[4])},{s(u[3])},{u[6]},{s(u[7])});")
lines.append("")

# 店铺
lines.append("-- 店铺")
for sh in shops:
    lines.append("INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES "
                 f"({sh[0]},{s(sh[1])},{s(sh[2])},{s(sh[3])},{s(sh[4])},{sh[5]},{sh[6]},{s(sh[7])},{s(sh[8])},{sh[9]},{sh[10]},{sh[11]},{sh[12]},{sh[13]},{s(sh[14])});")
lines.append("")

# 菜品
lines.append("-- 菜品")
for d in dishes:
    lines.append("INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES "
                 f"({d[0]},{d[1]},{s(d[2])},{s(d[3])},{d[4]},{s(d[5])},{s(d[6])},{d[7]},{d[8]},{d[9]},{s(d[10])});")
lines.append("")

# 地址
lines.append("-- 收货地址")
for a in addresses:
    lines.append("INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES "
                 f"({a[0]},{a[1]},{s(a[2])},{s(a[3])},{s(a[4])},{a[5]});")
lines.append("")

# 订单
lines.append("-- 订单")
for o in orders:
    lines.append("INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES "
                 f"({o[0]},{s(o[1])},{o[2]},{o[3]},{o[4]},{o[5]},{o[6]},{o[7]},{o[8]},{s(o[9])},{s(o[10])},{s(o[11])},{s(o[12])},{s(o[13])});")
lines.append("")

# 订单明细
lines.append("-- 订单明细")
for it in order_items:
    lines.append("INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES "
                 f"({it[0]},{it[1]},{it[2]},{s(it[3])},{s(it[4])},{it[5]},{it[6]});")
lines.append("")

# 评价
lines.append("-- 评价")
for rv in reviews:
    lines.append("INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES "
                 f"({rv[0]},{rv[1]},{rv[2]},{rv[3]},{rv[4]},{s(rv[5])},{s(rv[6])},{s(rv[7])},{s(rv[8])});")
lines.append("")

# 公告
lines.append("-- 公告")
for i, (t, c) in enumerate(notices_data):
    lines.append(f"INSERT INTO notice(id,title,content,create_time) VALUES ({i+1},{s(t)},{s(c)},{s(dt(rand_time(120)))});")
lines.append("")

with open(os.path.join(BASE, "init.sql"), "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

print("用户数:", len(users), " 店铺:", len(shops), " 菜品:", len(dishes),
      " 地址:", len(addresses), " 订单:", len(orders), " 明细:", len(order_items),
      " 评价:", len(reviews))
print("图片目录:", UP)
