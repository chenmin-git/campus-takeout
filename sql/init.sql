-- 校园外卖系统 建库建表 + 演示数据（自动生成）
SET NAMES utf8mb4;
DROP DATABASE IF EXISTS campus_takeout;
CREATE DATABASE campus_takeout DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE campus_takeout;


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
  rider_id BIGINT NULL COMMENT '配送员ID，骑手抢单后写入',
  address_snapshot VARCHAR(255),
  remark VARCHAR(255),
  create_time DATETIME,
  pay_time DATETIME,
  finish_time DATETIME,
  accept_time DATETIME COMMENT '商家接单时间，配送时效计时起点',
  sla_deadline DATETIME COMMENT '配送截止时间=接单时间+60分钟，延期获批后顺延',
  extend_status TINYINT DEFAULT 0 COMMENT '延期申请：0无1待用户审批2已同意3已拒绝',
  extend_minutes INT COMMENT '骑手申请延长的分钟数',
  extend_reason VARCHAR(255) COMMENT '骑手申请延期的原因',
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

-- 店铺分类
INSERT INTO shop_category(id,name,icon,sort) VALUES (1,'快餐简餐','uploads/category/cat_1.jpg',0);
INSERT INTO shop_category(id,name,icon,sort) VALUES (2,'奶茶饮品','uploads/category/cat_2.jpg',1);
INSERT INTO shop_category(id,name,icon,sort) VALUES (3,'米饭套餐','uploads/category/cat_3.jpg',2);
INSERT INTO shop_category(id,name,icon,sort) VALUES (4,'面食粉面','uploads/category/cat_4.jpg',3);
INSERT INTO shop_category(id,name,icon,sort) VALUES (5,'烧烤夜宵','uploads/category/cat_5.jpg',4);
INSERT INTO shop_category(id,name,icon,sort) VALUES (6,'甜品烘焙','uploads/category/cat_6.jpg',5);
INSERT INTO shop_category(id,name,icon,sort) VALUES (7,'营养早餐','uploads/category/cat_7.jpg',6);
INSERT INTO shop_category(id,name,icon,sort) VALUES (8,'轻食沙拉','uploads/category/cat_8.jpg',7);

-- 用户
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (1,'admin','e10adc3949ba59abbe56e057f20f883e','系统管理员','uploads/avatar/a_1.jpg','13800000000','ADMIN',1,'2025-12-01 09:00:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (2,'merchant1','e10adc3949ba59abbe56e057f20f883e','张亮','uploads/avatar/a_1.jpg','13900000000','MERCHANT',1,'2026-05-16 19:10:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (3,'merchant2','e10adc3949ba59abbe56e057f20f883e','一点点','uploads/avatar/a_2.jpg','13900000001','MERCHANT',1,'2026-04-27 11:11:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (4,'merchant3','e10adc3949ba59abbe56e057f20f883e','黄记老板','uploads/avatar/a_3.jpg','13900000002','MERCHANT',1,'2026-05-06 23:03:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (5,'merchant4','e10adc3949ba59abbe56e057f20f883e','马师傅','uploads/avatar/a_4.jpg','13900000003','MERCHANT',1,'2026-01-27 20:43:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (6,'merchant5','e10adc3949ba59abbe56e057f20f883e','烧烤老王','uploads/avatar/a_5.jpg','13900000004','MERCHANT',1,'2025-12-29 22:35:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (7,'merchant6','e10adc3949ba59abbe56e057f20f883e','甜心姐','uploads/avatar/a_6.jpg','13900000005','MERCHANT',1,'2026-02-04 21:56:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (8,'merchant7','e10adc3949ba59abbe56e057f20f883e','早餐铺老板','uploads/avatar/a_7.jpg','13900000006','MERCHANT',1,'2026-04-27 00:04:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (9,'merchant8','e10adc3949ba59abbe56e057f20f883e','轻食店主','uploads/avatar/a_8.jpg','13900000007','MERCHANT',1,'2026-01-22 22:13:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (10,'merchant9','e10adc3949ba59abbe56e057f20f883e','汉堡王店长','uploads/avatar/a_9.jpg','13900000008','MERCHANT',1,'2026-01-03 20:38:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (11,'merchant10','e10adc3949ba59abbe56e057f20f883e','CoCo店长','uploads/avatar/a_10.jpg','13900000009','MERCHANT',1,'2026-03-21 14:05:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (12,'merchant11','e10adc3949ba59abbe56e057f20f883e','面馆老李','uploads/avatar/a_1.jpg','13900000010','MERCHANT',1,'2026-03-23 10:57:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (13,'merchant12','e10adc3949ba59abbe56e057f20f883e','烧烤小哥','uploads/avatar/a_2.jpg','13900000011','MERCHANT',1,'2026-04-05 07:19:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (14,'merchant13','e10adc3949ba59abbe56e057f20f883e','新茶饮老板','uploads/avatar/a_3.jpg','13900000012','MERCHANT',1,'2026-04-27 05:50:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (15,'merchant14','e10adc3949ba59abbe56e057f20f883e','香锅老板','uploads/avatar/a_4.jpg','13900000013','MERCHANT',1,'2026-01-10 17:44:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (16,'merchant15','e10adc3949ba59abbe56e057f20f883e','小吃铺主','uploads/avatar/a_5.jpg','13900000014','MERCHANT',1,'2026-03-09 18:16:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (17,'user1','e10adc3949ba59abbe56e057f20f883e','小明','uploads/avatar/a_1.jpg','13700000000','USER',1,'2026-05-24 22:40:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (18,'user2','e10adc3949ba59abbe56e057f20f883e','小红','uploads/avatar/a_2.jpg','13700000001','USER',1,'2026-04-20 22:56:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (19,'user3','e10adc3949ba59abbe56e057f20f883e','李雷','uploads/avatar/a_3.jpg','13700000002','USER',1,'2026-04-28 11:28:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (20,'user4','e10adc3949ba59abbe56e057f20f883e','韩梅梅','uploads/avatar/a_4.jpg','13700000003','USER',1,'2026-04-28 17:06:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (21,'user5','e10adc3949ba59abbe56e057f20f883e','王小二','uploads/avatar/a_5.jpg','13700000004','USER',1,'2026-06-06 09:14:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (22,'user6','e10adc3949ba59abbe56e057f20f883e','赵四','uploads/avatar/a_6.jpg','13700000005','USER',1,'2026-04-15 11:46:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (23,'user7','e10adc3949ba59abbe56e057f20f883e','刘能','uploads/avatar/a_7.jpg','13700000006','USER',1,'2026-05-01 17:38:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (24,'user8','e10adc3949ba59abbe56e057f20f883e','谢广坤','uploads/avatar/a_8.jpg','13700000007','USER',1,'2026-04-23 03:49:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (25,'user9','e10adc3949ba59abbe56e057f20f883e','宋小宝','uploads/avatar/a_9.jpg','13700000008','USER',1,'2026-02-20 06:28:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (26,'user10','e10adc3949ba59abbe56e057f20f883e','周杰','uploads/avatar/a_10.jpg','13700000009','USER',1,'2026-03-22 11:33:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (27,'user11','e10adc3949ba59abbe56e057f20f883e','陈乔恩','uploads/avatar/a_1.jpg','13700000010','USER',1,'2026-01-04 03:35:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (28,'user12','e10adc3949ba59abbe56e057f20f883e','林志玲','uploads/avatar/a_2.jpg','13700000011','USER',1,'2026-02-16 23:21:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (29,'user13','e10adc3949ba59abbe56e057f20f883e','黄渤','uploads/avatar/a_3.jpg','13700000012','USER',1,'2026-05-07 01:37:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (30,'user14','e10adc3949ba59abbe56e057f20f883e','徐峥','uploads/avatar/a_4.jpg','13700000013','USER',1,'2026-06-01 13:54:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (31,'user15','e10adc3949ba59abbe56e057f20f883e','沈腾','uploads/avatar/a_5.jpg','13700000014','USER',1,'2026-02-13 02:26:00');
-- 配送员（骑手）账号，密码均为 123456
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (32,'rider1','e10adc3949ba59abbe56e057f20f883e','闪电骑手·阿强','uploads/avatar/a_6.jpg','13600000000','RIDER',1,'2026-01-15 08:00:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (33,'rider2','e10adc3949ba59abbe56e057f20f883e','飞毛腿·小李','uploads/avatar/a_7.jpg','13600000001','RIDER',1,'2026-02-10 08:30:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (34,'rider3','e10adc3949ba59abbe56e057f20f883e','风火轮·老周','uploads/avatar/a_8.jpg','13600000002','RIDER',1,'2026-03-12 09:00:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (35,'rider4','e10adc3949ba59abbe56e057f20f883e','极速达·小王','uploads/avatar/a_9.jpg','13600000003','RIDER',1,'2026-04-18 07:50:00');
INSERT INTO user(id,username,password,nickname,avatar,phone,role,status,create_time) VALUES (36,'rider5','e10adc3949ba59abbe56e057f20f883e','准时送·阿明','uploads/avatar/a_10.jpg','13600000004','RIDER',1,'2026-05-22 08:10:00');

-- 店铺
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (1,'张亮汉堡快餐店','uploads/shop/logo_1.jpg','uploads/shop/cover_1.jpg','张亮汉堡快餐店，主营快餐简餐，校园人气好店。',1,2,'第一食堂一楼','夜宵时段加量不加价',2,15,4.2,1619,1,'2025-12-31 05:12:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (2,'一点点奶茶(南门店)','uploads/shop/logo_2.jpg','uploads/shop/cover_2.jpg','一点点奶茶(南门店)，主营奶茶饮品，校园人气好店。',2,3,'南门美食街12号','招牌套餐买一送一',3,25,4.7,1985,1,'2026-05-25 20:11:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (3,'黄焖鸡米饭旗舰店','uploads/shop/logo_3.jpg','uploads/shop/cover_3.jpg','黄焖鸡米饭旗舰店，主营米饭套餐，校园人气好店。',3,4,'东区商业街','下雨天配送可能延迟，请耐心等待',3,30,4.8,1017,1,'2026-02-11 01:57:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (4,'兰州牛肉拉面馆','uploads/shop/logo_4.jpg','uploads/shop/cover_4.jpg','兰州牛肉拉面馆，主营面食粉面，校园人气好店。',4,5,'学生公寓3栋底商','满30减5，欢迎下单！',3,15,4.7,409,1,'2026-02-17 18:05:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (5,'深夜食堂烧烤','uploads/shop/logo_5.jpg','uploads/shop/cover_5.jpg','深夜食堂烧烤，主营烧烤夜宵，校园人气好店。',5,6,'图书馆负一层','营业时间 9:00-22:00',5,20,4.4,1508,1,'2026-04-12 03:08:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (6,'甜心烘焙坊','uploads/shop/logo_6.jpg','uploads/shop/cover_6.jpg','甜心烘焙坊，主营甜品烘焙，校园人气好店。',6,7,'西门小吃街','夜宵时段加量不加价',2,15,4.6,3200,1,'2026-01-25 16:46:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (7,'元气营养早餐铺','uploads/shop/logo_7.jpg','uploads/shop/cover_7.jpg','元气营养早餐铺，主营营养早餐，校园人气好店。',7,8,'北苑食堂二楼','本店新品上线，敬请品尝~',5,20,4.0,2335,1,'2026-05-30 17:59:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (8,'轻享健康轻食','uploads/shop/logo_8.jpg','uploads/shop/cover_8.jpg','轻享健康轻食，主营轻食沙拉，校园人气好店。',8,9,'体育馆旁商铺','招牌套餐买一送一',0,20,4.6,2671,1,'2026-02-15 17:32:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (9,'汉堡王(东区店)','uploads/shop/logo_9.jpg','uploads/shop/cover_9.jpg','汉堡王(东区店)，主营快餐简餐，校园人气好店。',1,10,'桃园餐厅','本店新品上线，敬请品尝~',0,15,4.0,1365,1,'2026-03-10 13:21:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (10,'CoCo都可奶茶','uploads/shop/logo_10.jpg','uploads/shop/cover_10.jpg','CoCo都可奶茶，主营奶茶饮品，校园人气好店。',2,11,'梅园美食广场','支持线上点单，到店自取',5,15,4.2,2064,1,'2026-01-31 12:13:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (11,'老碗面食馆','uploads/shop/logo_11.jpg','uploads/shop/cover_11.jpg','老碗面食馆，主营面食粉面，校园人气好店。',4,12,'竹园小吃城','支持线上点单，到店自取',3,20,4.5,494,1,'2026-04-05 01:55:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (12,'校园风味烧烤摊','uploads/shop/logo_12.jpg','uploads/shop/cover_12.jpg','校园风味烧烤摊，主营烧烤夜宵，校园人气好店。',5,13,'听涛苑底商','夜宵时段加量不加价',2,25,4.5,2123,1,'2026-04-17 04:39:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (13,'待审核·新晋茶饮店','uploads/shop/logo_13.jpg','uploads/shop/cover_13.jpg','待审核·新晋茶饮店，主营奶茶饮品，校园人气好店。',2,14,'新晋创业园','满30减5，欢迎下单！',1,25,4.0,28,0,'2026-05-02 00:06:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (14,'待审核·麻辣香锅快餐','uploads/shop/logo_14.jpg','uploads/shop/cover_14.jpg','待审核·麻辣香锅快餐，主营快餐简餐，校园人气好店。',1,15,'美食街待租位','满30减5，欢迎下单！',0,25,4.2,1,0,'2026-03-26 04:23:00');
INSERT INTO shop(id,name,logo,cover,description,category_id,owner_id,address,notice,delivery_fee,min_amount,rating,sales,status,create_time) VALUES (15,'被驳回·三无小吃铺','uploads/shop/logo_15.jpg','uploads/shop/cover_15.jpg','被驳回·三无小吃铺，主营烧烤夜宵，校园人气好店。',5,16,'已下架','本店新品上线，敬请品尝~',3,20,4.5,19,3,'2025-12-29 19:22:00');

-- 菜品
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (1,1,'香辣鸡腿堡','uploads/dish/d_1_1.jpg',19.5,'香辣鸡腿堡，张亮汉堡快餐店招牌出品','快餐简餐',273,63,1,'2026-04-03 19:49:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (2,1,'黄金鸡块','uploads/dish/d_1_2.jpg',13.2,'黄金鸡块，张亮汉堡快餐店招牌出品','快餐简餐',60,190,1,'2026-03-31 20:04:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (3,1,'薯条(大)','uploads/dish/d_1_3.jpg',28.7,'薯条(大)，张亮汉堡快餐店招牌出品','快餐简餐',270,91,1,'2026-06-01 14:11:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (4,1,'劲脆鸡排饭','uploads/dish/d_1_4.jpg',32.2,'劲脆鸡排饭，张亮汉堡快餐店招牌出品','快餐简餐',347,20,1,'2026-06-08 07:22:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (5,1,'照烧鸡腿堡','uploads/dish/d_1_5.jpg',9.3,'照烧鸡腿堡，张亮汉堡快餐店招牌出品','快餐简餐',598,194,1,'2026-04-30 06:30:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (6,1,'可乐鸡翅','uploads/dish/d_1_6.jpg',25.9,'可乐鸡翅，张亮汉堡快餐店招牌出品','快餐简餐',164,70,1,'2026-01-29 05:13:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (7,2,'珍珠奶茶','uploads/dish/d_2_1.jpg',10.3,'珍珠奶茶，一点点奶茶(南门店)招牌出品','奶茶饮品',722,35,1,'2026-03-07 02:02:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (8,2,'杨枝甘露','uploads/dish/d_2_2.jpg',13.9,'杨枝甘露，一点点奶茶(南门店)招牌出品','奶茶饮品',3,79,1,'2026-03-05 18:21:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (9,2,'芝芝莓莓','uploads/dish/d_2_3.jpg',12.7,'芝芝莓莓，一点点奶茶(南门店)招牌出品','奶茶饮品',111,131,1,'2026-02-01 14:11:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (10,2,'百香果茶','uploads/dish/d_2_4.jpg',25.7,'百香果茶，一点点奶茶(南门店)招牌出品','奶茶饮品',59,151,1,'2026-05-18 13:25:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (11,2,'招牌奶绿','uploads/dish/d_2_5.jpg',22.2,'招牌奶绿，一点点奶茶(南门店)招牌出品','奶茶饮品',145,138,1,'2026-05-29 00:35:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (12,2,'黑糖波波','uploads/dish/d_2_6.jpg',23.4,'黑糖波波，一点点奶茶(南门店)招牌出品','奶茶饮品',115,50,1,'2026-03-19 17:13:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (13,3,'黄焖鸡米饭','uploads/dish/d_3_1.jpg',14.8,'黄焖鸡米饭，黄焖鸡米饭旗舰店招牌出品','米饭套餐',266,145,1,'2026-02-07 21:32:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (14,3,'宫保鸡丁饭','uploads/dish/d_3_2.jpg',34.0,'宫保鸡丁饭，黄焖鸡米饭旗舰店招牌出品','米饭套餐',174,38,1,'2026-01-20 03:09:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (15,3,'红烧肉盖饭','uploads/dish/d_3_3.jpg',15.4,'红烧肉盖饭，黄焖鸡米饭旗舰店招牌出品','米饭套餐',79,86,1,'2026-04-05 15:15:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (16,3,'土豆牛肉饭','uploads/dish/d_3_4.jpg',9.6,'土豆牛肉饭，黄焖鸡米饭旗舰店招牌出品','米饭套餐',485,92,1,'2026-05-16 22:00:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (17,3,'鱼香肉丝饭','uploads/dish/d_3_5.jpg',32.9,'鱼香肉丝饭，黄焖鸡米饭旗舰店招牌出品','米饭套餐',60,193,1,'2026-01-20 13:49:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (18,3,'排骨饭','uploads/dish/d_3_6.jpg',25.3,'排骨饭，黄焖鸡米饭旗舰店招牌出品','米饭套餐',468,27,1,'2026-04-14 16:01:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (19,3,'麻婆豆腐饭','uploads/dish/d_3_7.jpg',31.0,'麻婆豆腐饭，黄焖鸡米饭旗舰店招牌出品','米饭套餐',251,157,1,'2026-02-25 12:34:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (20,3,'咖喱鸡饭','uploads/dish/d_3_8.jpg',28.2,'咖喱鸡饭，黄焖鸡米饭旗舰店招牌出品','米饭套餐',508,141,1,'2026-05-10 00:33:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (21,4,'牛肉拉面','uploads/dish/d_4_1.jpg',29.5,'牛肉拉面，兰州牛肉拉面馆招牌出品','面食粉面',290,187,1,'2026-03-26 20:42:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (22,4,'酸辣粉','uploads/dish/d_4_2.jpg',11.4,'酸辣粉，兰州牛肉拉面馆招牌出品','面食粉面',645,64,1,'2026-04-16 12:58:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (23,4,'重庆小面','uploads/dish/d_4_3.jpg',20.6,'重庆小面，兰州牛肉拉面馆招牌出品','面食粉面',352,37,1,'2026-03-09 07:23:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (24,4,'番茄鸡蛋面','uploads/dish/d_4_4.jpg',8.2,'番茄鸡蛋面，兰州牛肉拉面馆招牌出品','面食粉面',22,90,1,'2026-01-20 11:31:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (25,4,'螺蛳粉','uploads/dish/d_4_5.jpg',22.4,'螺蛳粉，兰州牛肉拉面馆招牌出品','面食粉面',644,47,1,'2026-05-30 16:13:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (26,4,'炸酱面','uploads/dish/d_4_6.jpg',28.0,'炸酱面，兰州牛肉拉面馆招牌出品','面食粉面',366,193,1,'2026-06-04 12:42:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (27,4,'热干面','uploads/dish/d_4_7.jpg',14.1,'热干面，兰州牛肉拉面馆招牌出品','面食粉面',364,87,1,'2026-06-01 09:15:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (28,4,'鸭血粉丝汤','uploads/dish/d_4_8.jpg',21.0,'鸭血粉丝汤，兰州牛肉拉面馆招牌出品','面食粉面',146,125,1,'2026-04-13 12:22:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (29,5,'烤羊肉串(10串)','uploads/dish/d_5_1.jpg',24.0,'烤羊肉串(10串)，深夜食堂烧烤招牌出品','烧烤夜宵',140,76,1,'2026-03-16 17:43:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (30,5,'烤鸡翅','uploads/dish/d_5_2.jpg',24.8,'烤鸡翅，深夜食堂烧烤招牌出品','烧烤夜宵',114,34,1,'2026-04-13 22:05:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (31,5,'烤韭菜','uploads/dish/d_5_3.jpg',31.3,'烤韭菜，深夜食堂烧烤招牌出品','烧烤夜宵',543,35,1,'2026-03-13 05:28:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (32,5,'烤金针菇','uploads/dish/d_5_4.jpg',23.7,'烤金针菇，深夜食堂烧烤招牌出品','烧烤夜宵',411,25,1,'2026-03-08 15:12:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (33,5,'烤茄子','uploads/dish/d_5_5.jpg',18.5,'烤茄子，深夜食堂烧烤招牌出品','烧烤夜宵',730,185,1,'2026-03-23 12:38:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (34,5,'烤五花肉','uploads/dish/d_5_6.jpg',20.7,'烤五花肉，深夜食堂烧烤招牌出品','烧烤夜宵',615,34,1,'2026-04-18 16:47:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (35,5,'烤玉米','uploads/dish/d_5_7.jpg',26.9,'烤玉米，深夜食堂烧烤招牌出品','烧烤夜宵',463,150,1,'2026-03-16 13:04:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (36,5,'麻辣小龙虾','uploads/dish/d_5_8.jpg',27.7,'麻辣小龙虾，深夜食堂烧烤招牌出品','烧烤夜宵',274,98,1,'2026-03-27 04:27:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (37,6,'提拉米苏','uploads/dish/d_6_1.jpg',10.7,'提拉米苏，甜心烘焙坊招牌出品','甜品烘焙',589,152,1,'2026-03-29 14:24:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (38,6,'芒果千层','uploads/dish/d_6_2.jpg',27.5,'芒果千层，甜心烘焙坊招牌出品','甜品烘焙',757,114,1,'2026-02-09 21:58:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (39,6,'草莓蛋糕','uploads/dish/d_6_3.jpg',18.0,'草莓蛋糕，甜心烘焙坊招牌出品','甜品烘焙',220,87,1,'2026-06-08 00:34:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (40,6,'巧克力慕斯','uploads/dish/d_6_4.jpg',14.9,'巧克力慕斯，甜心烘焙坊招牌出品','甜品烘焙',490,146,1,'2026-03-19 11:16:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (41,6,'蛋挞(2个)','uploads/dish/d_6_5.jpg',10.6,'蛋挞(2个)，甜心烘焙坊招牌出品','甜品烘焙',399,20,1,'2026-04-24 21:20:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (42,6,'双皮奶','uploads/dish/d_6_6.jpg',8.7,'双皮奶，甜心烘焙坊招牌出品','甜品烘焙',414,196,1,'2026-02-13 15:06:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (43,6,'舒芙蕾','uploads/dish/d_6_7.jpg',34.0,'舒芙蕾，甜心烘焙坊招牌出品','甜品烘焙',447,106,1,'2026-06-02 05:05:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (44,6,'红豆双皮奶','uploads/dish/d_6_8.jpg',10.8,'红豆双皮奶，甜心烘焙坊招牌出品','甜品烘焙',281,141,1,'2026-01-16 17:27:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (45,7,'皮蛋瘦肉粥','uploads/dish/d_7_1.jpg',30.1,'皮蛋瘦肉粥，元气营养早餐铺招牌出品','营养早餐',72,103,1,'2026-02-06 23:43:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (46,7,'小笼包(6个)','uploads/dish/d_7_2.jpg',17.1,'小笼包(6个)，元气营养早餐铺招牌出品','营养早餐',336,35,1,'2026-03-09 21:03:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (47,7,'豆浆油条','uploads/dish/d_7_3.jpg',14.2,'豆浆油条，元气营养早餐铺招牌出品','营养早餐',329,44,1,'2026-03-07 20:11:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (48,7,'鲜肉包','uploads/dish/d_7_4.jpg',34.5,'鲜肉包，元气营养早餐铺招牌出品','营养早餐',514,38,1,'2026-02-14 15:47:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (49,7,'蒸饺(8个)','uploads/dish/d_7_5.jpg',28.0,'蒸饺(8个)，元气营养早餐铺招牌出品','营养早餐',176,94,1,'2026-05-23 15:11:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (50,7,'煎蛋三明治','uploads/dish/d_7_6.jpg',14.7,'煎蛋三明治，元气营养早餐铺招牌出品','营养早餐',638,61,1,'2026-04-16 08:21:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (51,7,'南瓜粥','uploads/dish/d_7_7.jpg',37.4,'南瓜粥，元气营养早餐铺招牌出品','营养早餐',432,154,1,'2026-05-06 20:59:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (52,8,'鸡胸肉沙拉','uploads/dish/d_8_1.jpg',31.9,'鸡胸肉沙拉，轻享健康轻食招牌出品','轻食沙拉',73,177,1,'2026-02-26 07:32:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (53,8,'牛油果沙拉','uploads/dish/d_8_2.jpg',24.1,'牛油果沙拉，轻享健康轻食招牌出品','轻食沙拉',672,61,1,'2026-02-23 00:09:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (54,8,'藜麦缤纷沙拉','uploads/dish/d_8_3.jpg',37.9,'藜麦缤纷沙拉，轻享健康轻食招牌出品','轻食沙拉',275,196,1,'2026-04-23 07:15:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (55,8,'金枪鱼沙拉','uploads/dish/d_8_4.jpg',14.1,'金枪鱼沙拉，轻享健康轻食招牌出品','轻食沙拉',601,101,1,'2026-03-28 15:04:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (56,8,'水果酸奶碗','uploads/dish/d_8_5.jpg',9.1,'水果酸奶碗，轻享健康轻食招牌出品','轻食沙拉',531,34,1,'2026-04-12 02:31:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (57,8,'全麦鸡蛋卷','uploads/dish/d_8_6.jpg',36.0,'全麦鸡蛋卷，轻享健康轻食招牌出品','轻食沙拉',684,45,1,'2026-03-21 09:07:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (58,8,'缤纷蔬菜杯','uploads/dish/d_8_7.jpg',33.3,'缤纷蔬菜杯，轻享健康轻食招牌出品','轻食沙拉',308,38,1,'2026-04-18 03:24:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (59,8,'低脂能量碗','uploads/dish/d_8_8.jpg',36.8,'低脂能量碗，轻享健康轻食招牌出品','轻食沙拉',588,74,1,'2026-04-27 08:32:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (60,9,'香辣鸡腿堡','uploads/dish/d_1_1.jpg',10.2,'香辣鸡腿堡，汉堡王(东区店)招牌出品','快餐简餐',444,147,1,'2026-04-14 14:52:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (61,9,'黄金鸡块','uploads/dish/d_1_2.jpg',36.0,'黄金鸡块，汉堡王(东区店)招牌出品','快餐简餐',419,183,1,'2026-05-06 08:04:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (62,9,'薯条(大)','uploads/dish/d_1_3.jpg',22.2,'薯条(大)，汉堡王(东区店)招牌出品','快餐简餐',712,140,1,'2026-04-26 08:24:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (63,9,'劲脆鸡排饭','uploads/dish/d_1_4.jpg',24.8,'劲脆鸡排饭，汉堡王(东区店)招牌出品','快餐简餐',452,72,1,'2026-02-03 09:36:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (64,9,'照烧鸡腿堡','uploads/dish/d_1_5.jpg',29.9,'照烧鸡腿堡，汉堡王(东区店)招牌出品','快餐简餐',377,44,1,'2026-03-31 13:10:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (65,9,'可乐鸡翅','uploads/dish/d_1_6.jpg',19.2,'可乐鸡翅，汉堡王(东区店)招牌出品','快餐简餐',583,123,1,'2026-03-25 08:11:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (66,9,'牛肉汉堡','uploads/dish/d_1_7.jpg',12.6,'牛肉汉堡，汉堡王(东区店)招牌出品','快餐简餐',312,115,1,'2026-04-02 13:09:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (67,9,'原味炸鸡','uploads/dish/d_1_8.jpg',13.8,'原味炸鸡，汉堡王(东区店)招牌出品','快餐简餐',668,108,1,'2026-02-27 23:30:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (68,10,'珍珠奶茶','uploads/dish/d_2_1.jpg',13.8,'珍珠奶茶，CoCo都可奶茶招牌出品','奶茶饮品',131,86,1,'2026-03-04 23:22:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (69,10,'杨枝甘露','uploads/dish/d_2_2.jpg',8.7,'杨枝甘露，CoCo都可奶茶招牌出品','奶茶饮品',563,69,1,'2026-01-14 05:16:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (70,10,'芝芝莓莓','uploads/dish/d_2_3.jpg',30.7,'芝芝莓莓，CoCo都可奶茶招牌出品','奶茶饮品',412,41,1,'2026-04-27 17:39:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (71,10,'百香果茶','uploads/dish/d_2_4.jpg',35.7,'百香果茶，CoCo都可奶茶招牌出品','奶茶饮品',783,22,1,'2026-06-11 08:55:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (72,10,'招牌奶绿','uploads/dish/d_2_5.jpg',11.1,'招牌奶绿，CoCo都可奶茶招牌出品','奶茶饮品',477,142,1,'2026-03-31 00:48:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (73,10,'黑糖波波','uploads/dish/d_2_6.jpg',20.7,'黑糖波波，CoCo都可奶茶招牌出品','奶茶饮品',261,148,1,'2026-03-26 11:29:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (74,11,'牛肉拉面','uploads/dish/d_4_1.jpg',9.1,'牛肉拉面，老碗面食馆招牌出品','面食粉面',37,133,1,'2026-03-03 17:54:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (75,11,'酸辣粉','uploads/dish/d_4_2.jpg',22.7,'酸辣粉，老碗面食馆招牌出品','面食粉面',445,128,1,'2026-05-24 13:41:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (76,11,'重庆小面','uploads/dish/d_4_3.jpg',20.7,'重庆小面，老碗面食馆招牌出品','面食粉面',327,92,1,'2026-03-02 06:09:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (77,11,'番茄鸡蛋面','uploads/dish/d_4_4.jpg',24.6,'番茄鸡蛋面，老碗面食馆招牌出品','面食粉面',150,46,1,'2026-03-02 02:41:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (78,11,'螺蛳粉','uploads/dish/d_4_5.jpg',33.4,'螺蛳粉，老碗面食馆招牌出品','面食粉面',338,197,1,'2026-01-25 09:39:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (79,11,'炸酱面','uploads/dish/d_4_6.jpg',10.1,'炸酱面，老碗面食馆招牌出品','面食粉面',348,31,1,'2026-02-14 12:43:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (80,11,'热干面','uploads/dish/d_4_7.jpg',30.7,'热干面，老碗面食馆招牌出品','面食粉面',787,66,1,'2026-05-31 00:04:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (81,11,'鸭血粉丝汤','uploads/dish/d_4_8.jpg',37.0,'鸭血粉丝汤，老碗面食馆招牌出品','面食粉面',323,193,1,'2026-02-27 04:52:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (82,12,'烤羊肉串(10串)','uploads/dish/d_5_1.jpg',30.1,'烤羊肉串(10串)，校园风味烧烤摊招牌出品','烧烤夜宵',318,34,1,'2026-05-02 15:47:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (83,12,'烤鸡翅','uploads/dish/d_5_2.jpg',22.0,'烤鸡翅，校园风味烧烤摊招牌出品','烧烤夜宵',366,144,1,'2026-06-03 18:12:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (84,12,'烤韭菜','uploads/dish/d_5_3.jpg',30.9,'烤韭菜，校园风味烧烤摊招牌出品','烧烤夜宵',670,75,1,'2026-04-30 21:06:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (85,12,'烤金针菇','uploads/dish/d_5_4.jpg',10.5,'烤金针菇，校园风味烧烤摊招牌出品','烧烤夜宵',728,78,1,'2026-03-22 18:31:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (86,12,'烤茄子','uploads/dish/d_5_5.jpg',13.4,'烤茄子，校园风味烧烤摊招牌出品','烧烤夜宵',606,172,1,'2026-03-21 11:29:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (87,12,'烤五花肉','uploads/dish/d_5_6.jpg',12.5,'烤五花肉，校园风味烧烤摊招牌出品','烧烤夜宵',604,104,1,'2026-02-26 13:15:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (88,12,'烤玉米','uploads/dish/d_5_7.jpg',31.8,'烤玉米，校园风味烧烤摊招牌出品','烧烤夜宵',90,163,1,'2026-04-04 18:56:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (89,12,'麻辣小龙虾','uploads/dish/d_5_8.jpg',10.2,'麻辣小龙虾，校园风味烧烤摊招牌出品','烧烤夜宵',751,198,1,'2026-05-05 19:43:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (90,13,'珍珠奶茶','uploads/dish/d_2_1.jpg',27.5,'珍珠奶茶，待审核·新晋茶饮店招牌出品','奶茶饮品',299,74,1,'2026-04-25 17:47:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (91,13,'杨枝甘露','uploads/dish/d_2_2.jpg',21.8,'杨枝甘露，待审核·新晋茶饮店招牌出品','奶茶饮品',203,21,1,'2026-03-10 16:49:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (92,13,'芝芝莓莓','uploads/dish/d_2_3.jpg',20.0,'芝芝莓莓，待审核·新晋茶饮店招牌出品','奶茶饮品',469,59,1,'2026-03-29 19:59:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (93,13,'百香果茶','uploads/dish/d_2_4.jpg',14.9,'百香果茶，待审核·新晋茶饮店招牌出品','奶茶饮品',233,63,1,'2026-05-25 10:02:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (94,13,'招牌奶绿','uploads/dish/d_2_5.jpg',33.8,'招牌奶绿，待审核·新晋茶饮店招牌出品','奶茶饮品',565,79,1,'2026-06-11 16:25:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (95,13,'黑糖波波','uploads/dish/d_2_6.jpg',11.2,'黑糖波波，待审核·新晋茶饮店招牌出品','奶茶饮品',36,146,1,'2026-03-03 15:47:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (96,13,'柠檬蜂蜜茶','uploads/dish/d_2_7.jpg',10.6,'柠檬蜂蜜茶，待审核·新晋茶饮店招牌出品','奶茶饮品',537,107,1,'2026-02-26 03:36:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (97,14,'香辣鸡腿堡','uploads/dish/d_1_1.jpg',26.0,'香辣鸡腿堡，待审核·麻辣香锅快餐招牌出品','快餐简餐',608,162,1,'2026-03-27 05:00:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (98,14,'黄金鸡块','uploads/dish/d_1_2.jpg',21.3,'黄金鸡块，待审核·麻辣香锅快餐招牌出品','快餐简餐',449,101,1,'2026-02-07 18:06:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (99,14,'薯条(大)','uploads/dish/d_1_3.jpg',17.6,'薯条(大)，待审核·麻辣香锅快餐招牌出品','快餐简餐',311,36,1,'2026-04-02 23:52:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (100,14,'劲脆鸡排饭','uploads/dish/d_1_4.jpg',35.8,'劲脆鸡排饭，待审核·麻辣香锅快餐招牌出品','快餐简餐',177,68,1,'2026-04-22 08:17:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (101,14,'照烧鸡腿堡','uploads/dish/d_1_5.jpg',26.3,'照烧鸡腿堡，待审核·麻辣香锅快餐招牌出品','快餐简餐',495,137,1,'2026-02-04 00:16:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (102,14,'可乐鸡翅','uploads/dish/d_1_6.jpg',14.1,'可乐鸡翅，待审核·麻辣香锅快餐招牌出品','快餐简餐',429,113,1,'2026-05-26 05:22:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (103,15,'烤羊肉串(10串)','uploads/dish/d_5_1.jpg',29.6,'烤羊肉串(10串)，被驳回·三无小吃铺招牌出品','烧烤夜宵',510,31,1,'2026-01-25 01:22:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (104,15,'烤鸡翅','uploads/dish/d_5_2.jpg',12.6,'烤鸡翅，被驳回·三无小吃铺招牌出品','烧烤夜宵',672,177,1,'2026-03-21 08:28:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (105,15,'烤韭菜','uploads/dish/d_5_3.jpg',27.3,'烤韭菜，被驳回·三无小吃铺招牌出品','烧烤夜宵',684,177,1,'2026-01-22 10:24:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (106,15,'烤金针菇','uploads/dish/d_5_4.jpg',29.2,'烤金针菇，被驳回·三无小吃铺招牌出品','烧烤夜宵',724,112,1,'2026-02-11 01:05:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (107,15,'烤茄子','uploads/dish/d_5_5.jpg',27.8,'烤茄子，被驳回·三无小吃铺招牌出品','烧烤夜宵',797,99,1,'2026-01-14 00:33:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (108,15,'烤五花肉','uploads/dish/d_5_6.jpg',34.0,'烤五花肉，被驳回·三无小吃铺招牌出品','烧烤夜宵',142,105,1,'2026-02-04 06:10:00');
INSERT INTO dish(id,shop_id,name,image,price,description,dish_category,sales,stock,status,create_time) VALUES (109,15,'烤玉米','uploads/dish/d_5_7.jpg',12.0,'烤玉米，被驳回·三无小吃铺招牌出品','烧烤夜宵',3,72,1,'2026-02-21 14:07:00');

-- 收货地址
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (1,17,'小明','13700000000','XX大学桃园宿舍277室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (2,17,'小明','13700000000','XX大学桃园宿舍124室',0);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (3,18,'小红','13700000001','XX大学体育馆519室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (4,18,'小红','13700000001','XX大学行政楼514室',0);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (5,19,'李雷','13700000002','XX大学行政楼127室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (6,20,'韩梅梅','13700000003','XX大学桃园宿舍497室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (7,21,'王小二','13700000004','XX大学体育馆126室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (8,22,'赵四','13700000005','XX大学第一教学楼206室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (9,23,'刘能','13700000006','XX大学实验楼172室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (10,23,'刘能','13700000006','XX大学桃园宿舍518室',0);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (11,24,'谢广坤','13700000007','XX大学图书馆166室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (12,24,'谢广坤','13700000007','XX大学图书馆439室',0);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (13,25,'宋小宝','13700000008','XX大学桃园宿舍386室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (14,25,'宋小宝','13700000008','XX大学南门473室',0);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (15,26,'周杰','13700000009','XX大学南门208室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (16,26,'周杰','13700000009','XX大学图书馆301室',0);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (17,27,'陈乔恩','13700000010','XX大学实验楼110室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (18,28,'林志玲','13700000011','XX大学图书馆471室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (19,28,'林志玲','13700000011','XX大学实验楼139室',0);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (20,29,'黄渤','13700000012','XX大学桃园宿舍168室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (21,29,'黄渤','13700000012','XX大学桃园宿舍146室',0);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (22,30,'徐峥','13700000013','XX大学学生公寓1栋136室',1);
INSERT INTO address(id,user_id,name,phone,detail,is_default) VALUES (23,31,'沈腾','13700000014','XX大学体育馆488室',1);

-- 订单
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (1,'202604091416001369',28,4,98.1,1.0,3.0,102.1,4,'XX大学南门330室','尽快配送','2026-04-09 14:16:00','2026-04-09 14:17:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (2,'202605061437009586',19,2,146.3,1.0,3.0,150.3,5,'XX大学桃园宿舍431室','餐具一份','2026-05-06 14:37:00','2026-05-06 14:42:00','2026-05-06 15:41:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (3,'202602051748008611',24,8,70.0,1.0,0.0,71.0,5,'XX大学行政楼499室','不要辣','2026-02-05 17:48:00','2026-02-05 17:49:00','2026-02-05 18:43:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (4,'202604021555003957',29,7,224.6,1.0,5.0,230.6,5,'XX大学梅园宿舍143室','','2026-04-02 15:55:00','2026-04-02 16:00:00','2026-04-02 17:01:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (5,'202603240339008747',31,10,8.7,1.0,5.0,14.7,3,'XX大学学生公寓5栋262室','餐具一份','2026-03-24 03:39:00','2026-03-24 03:42:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (6,'202606111626002484',27,6,43.7,1.0,2.0,46.7,5,'XX大学梅园宿舍280室','少冰','2026-06-11 16:26:00','2026-06-11 16:29:00','2026-06-11 17:07:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (7,'202604270327002119',17,7,261.7,1.0,5.0,267.7,5,'XX大学南门151室','不要辣','2026-04-27 03:27:00','2026-04-27 03:32:00','2026-04-27 04:35:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (8,'202602160503007158',21,6,140.7,1.0,2.0,143.7,5,'XX大学图书馆242室','少冰','2026-02-16 05:03:00','2026-02-16 05:06:00','2026-02-16 05:49:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (9,'202601200318007222',23,7,65.8,1.0,5.0,71.8,6,'XX大学体育馆430室','','2026-01-20 03:18:00','2026-01-20 03:21:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (10,'202606112008006207',27,12,173.2,1.0,2.0,176.2,3,'XX大学行政楼397室','少冰','2026-06-11 20:08:00','2026-06-11 20:09:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (11,'202601061145002531',19,4,157.2,1.0,3.0,161.2,4,'XX大学行政楼410室','送到宿舍楼下','2026-01-06 11:45:00','2026-01-06 11:47:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (12,'202602051749002627',18,11,94.1,1.0,3.0,98.1,5,'XX大学桃园宿舍436室','送到宿舍楼下','2026-02-05 17:49:00','2026-02-05 17:50:00','2026-02-05 18:37:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (13,'202602260957005070',17,4,143.2,1.0,3.0,147.2,3,'XX大学图书馆331室','送到宿舍楼下','2026-02-26 09:57:00','2026-02-26 10:01:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (14,'202605091010001510',26,6,27.5,1.0,2.0,30.5,3,'XX大学学生公寓5栋124室','餐具一份','2026-05-09 10:10:00','2026-05-09 10:15:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (15,'202605201043002040',18,7,152.7,1.0,5.0,158.7,6,'XX大学图书馆136室','','2026-05-20 10:43:00','2026-05-20 10:44:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (16,'202602131705005143',19,1,93.8,1.0,2.0,96.8,5,'XX大学桃园宿舍146室','','2026-02-13 17:05:00','2026-02-13 17:06:00','2026-02-13 17:37:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (17,'202601021840001902',25,5,91.3,1.0,5.0,97.3,5,'XX大学体育馆198室','餐具一份','2026-01-02 18:40:00','2026-01-02 18:43:00','2026-01-02 19:59:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (18,'202603250608006340',20,11,123.8,1.0,3.0,127.8,6,'XX大学学生公寓1栋435室','不要香菜','2026-03-25 06:08:00','2026-03-25 06:13:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (19,'202603171255008424',17,6,21.4,1.0,2.0,24.4,6,'XX大学实验楼459室','尽快配送','2026-03-17 12:55:00','2026-03-17 12:56:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (20,'202512310944009321',23,9,125.7,1.0,0.0,126.7,4,'XX大学体育馆296室','','2025-12-31 09:44:00','2025-12-31 09:46:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (21,'202602241213003275',29,1,25.9,1.0,2.0,28.9,5,'XX大学学生公寓5栋460室','','2026-02-24 12:13:00','2026-02-24 12:17:00','2026-02-24 12:46:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (22,'202606031040004751',20,6,157.3,1.0,2.0,160.3,5,'XX大学南门463室','','2026-06-03 10:40:00','2026-06-03 10:45:00','2026-06-03 11:18:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (23,'202605060023007006',24,4,134.1,1.0,3.0,138.1,6,'XX大学学生公寓1栋353室','少冰','2026-05-06 00:23:00','2026-05-06 00:25:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (24,'202605212059008879',23,2,146.9,1.0,3.0,150.9,6,'XX大学梅园宿舍295室','送到宿舍楼下','2026-05-21 20:59:00','2026-05-21 21:01:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (25,'202602280729008712',25,12,219.9,1.0,2.0,222.9,5,'XX大学图书馆209室','餐具一份','2026-02-28 07:29:00','2026-02-28 07:33:00','2026-02-28 08:37:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (26,'202604181908009802',17,5,249.0,1.0,5.0,255.0,3,'XX大学学生公寓1栋158室','餐具一份','2026-04-18 19:08:00','2026-04-18 19:11:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (27,'202605221113008024',27,8,146.5,1.0,0.0,147.5,5,'XX大学实验楼236室','送到宿舍楼下','2026-05-22 11:13:00','2026-05-22 11:14:00','2026-05-22 12:11:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (28,'202605100357003721',20,6,112.6,1.0,2.0,115.6,2,'XX大学学生公寓1栋391室','尽快配送','2026-05-10 03:57:00','2026-05-10 04:02:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (29,'202606102100007058',21,11,115.0,1.0,3.0,119.0,5,'XX大学南门482室','送到宿舍楼下','2026-06-10 21:00:00','2026-06-10 21:05:00','2026-06-10 21:40:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (30,'202605051231009515',17,8,33.3,1.0,0.0,34.3,5,'XX大学图书馆485室','餐具一份','2026-05-05 12:31:00','2026-05-05 12:33:00','2026-05-05 13:06:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (31,'202605071747007341',21,12,91.0,1.0,2.0,94.0,5,'XX大学南门199室','','2026-05-07 17:47:00','2026-05-07 17:50:00','2026-05-07 19:01:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (32,'202604082140007215',24,10,107.1,1.0,5.0,113.1,5,'XX大学梅园宿舍304室','少冰','2026-04-08 21:40:00','2026-04-08 21:42:00','2026-04-08 22:16:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (33,'202601312330004591',18,2,130.2,1.0,3.0,134.2,6,'XX大学行政楼416室','不要辣','2026-01-31 23:30:00','2026-01-31 23:31:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (34,'202603310505009861',23,10,71.4,1.0,5.0,77.4,5,'XX大学学生公寓1栋115室','不要辣','2026-03-31 05:05:00','2026-03-31 05:08:00','2026-03-31 05:55:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (35,'202601121600008284',29,8,163.8,1.0,0.0,164.8,5,'XX大学第一教学楼291室','','2026-01-12 16:00:00','2026-01-12 16:01:00','2026-01-12 16:38:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (36,'202605250438001091',18,11,70.8,1.0,3.0,74.8,5,'XX大学南门149室','餐具一份','2026-05-25 04:38:00','2026-05-25 04:40:00','2026-05-25 05:23:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (37,'202603131251005731',21,9,191.3,1.0,0.0,192.3,6,'XX大学梅园宿舍327室','少冰','2026-03-13 12:51:00','2026-03-13 12:54:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (38,'202601040658003821',20,6,32.3,1.0,2.0,35.3,5,'XX大学梅园宿舍480室','多加一份米饭','2026-01-04 06:58:00','2026-01-04 07:02:00','2026-01-04 08:05:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (39,'202604221201007383',25,4,67.2,1.0,3.0,71.2,6,'XX大学南门292室','少冰','2026-04-22 12:01:00','2026-04-22 12:04:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (40,'202603090636008280',20,7,160.3,1.0,5.0,166.3,6,'XX大学行政楼308室','不要香菜','2026-03-09 06:36:00','2026-03-09 06:40:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (41,'202604170606001126',30,3,123.8,1.0,3.0,127.8,5,'XX大学第一教学楼440室','尽快配送','2026-04-17 06:06:00','2026-04-17 06:11:00','2026-04-17 06:53:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (42,'202601080025001811',26,5,184.8,1.0,5.0,190.8,5,'XX大学学生公寓5栋488室','','2026-01-08 00:25:00','2026-01-08 00:26:00','2026-01-08 01:21:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (43,'202604042026001609',18,9,192.3,1.0,0.0,193.3,5,'XX大学第一教学楼466室','尽快配送','2026-04-04 20:26:00','2026-04-04 20:27:00','2026-04-04 21:29:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (44,'202604080104007945',19,3,114.6,1.0,3.0,118.6,5,'XX大学行政楼116室','不要辣','2026-04-08 01:04:00','2026-04-08 01:07:00','2026-04-08 02:18:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (45,'202512310204002869',21,4,119.9,1.0,3.0,123.9,6,'XX大学桃园宿舍181室','','2025-12-31 02:04:00','2025-12-31 02:06:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (46,'202602242352003850',27,4,56.0,1.0,3.0,60.0,4,'XX大学梅园宿舍181室','餐具一份','2026-02-24 23:52:00','2026-02-24 23:53:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (47,'202601251618002358',21,10,163.5,1.0,5.0,169.5,6,'XX大学第一教学楼407室','送到宿舍楼下','2026-01-25 16:18:00','2026-01-25 16:20:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (48,'202512261529008479',21,6,195.0,1.0,2.0,198.0,5,'XX大学实验楼475室','不要香菜','2025-12-26 15:29:00','2025-12-26 15:34:00','2025-12-26 16:16:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (49,'202602211830006012',29,9,66.6,1.0,0.0,67.6,4,'XX大学实验楼250室','不要辣','2026-02-21 18:30:00','2026-02-21 18:35:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (50,'202606090517002228',28,7,34.5,1.0,5.0,40.5,5,'XX大学体育馆152室','不要香菜','2026-06-09 05:17:00','2026-06-09 05:18:00','2026-06-09 06:24:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (51,'202603201156008526',22,1,199.4,1.0,2.0,202.4,5,'XX大学第一教学楼496室','多加一份米饭','2026-03-20 11:56:00','2026-03-20 12:01:00','2026-03-20 12:52:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (52,'202605120213005330',26,1,32.2,1.0,2.0,35.2,4,'XX大学学生公寓1栋131室','少冰','2026-05-12 02:13:00','2026-05-12 02:15:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (53,'202601161257006011',28,8,230.6,1.0,0.0,231.6,3,'XX大学体育馆326室','尽快配送','2026-01-16 12:57:00','2026-01-16 13:02:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (54,'202604161403001201',27,6,128.7,1.0,2.0,131.7,5,'XX大学学生公寓5栋144室','送到宿舍楼下','2026-04-16 14:03:00','2026-04-16 14:05:00','2026-04-16 14:39:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (55,'202603231146004137',26,12,154.7,1.0,2.0,157.7,5,'XX大学学生公寓1栋266室','','2026-03-23 11:46:00','2026-03-23 11:51:00','2026-03-23 12:52:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (56,'202512171723008530',28,9,125.8,1.0,0.0,126.8,2,'XX大学图书馆517室','','2025-12-17 17:23:00','2025-12-17 17:28:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (57,'202605240258002996',18,8,176.2,1.0,0.0,177.2,2,'XX大学桃园宿舍420室','尽快配送','2026-05-24 02:58:00','2026-05-24 02:59:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (58,'202604110316001372',17,4,73.1,1.0,3.0,77.1,3,'XX大学体育馆328室','送到宿舍楼下','2026-04-11 03:16:00','2026-04-11 03:20:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (59,'202605171121009086',24,10,61.2,1.0,5.0,67.2,3,'XX大学体育馆215室','不要香菜','2026-05-17 11:21:00','2026-05-17 11:24:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (60,'202604181438006587',28,12,22.0,1.0,2.0,25.0,6,'XX大学学生公寓5栋382室','尽快配送','2026-04-18 14:38:00','2026-04-18 14:42:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (61,'202605311628003479',21,3,32.9,1.0,3.0,36.9,5,'XX大学体育馆505室','送到宿舍楼下','2026-05-31 16:28:00','2026-05-31 16:31:00','2026-05-31 17:37:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (62,'202604260608009328',17,3,34.0,1.0,3.0,38.0,5,'XX大学行政楼147室','','2026-04-26 06:08:00','2026-04-26 06:09:00','2026-04-26 06:41:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (63,'202603120328005225',21,11,106.7,1.0,3.0,110.7,5,'XX大学梅园宿舍141室','多加一份米饭','2026-03-12 03:28:00','2026-03-12 03:30:00','2026-03-12 04:20:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (64,'202601080658003142',24,6,123.1,1.0,2.0,126.1,4,'XX大学学生公寓5栋475室','多加一份米饭','2026-01-08 06:58:00','2026-01-08 06:59:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (65,'202605022257008117',19,5,267.8,1.0,5.0,273.8,5,'XX大学学生公寓1栋458室','不要香菜','2026-05-02 22:57:00','2026-05-02 23:02:00','2026-05-02 23:42:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (66,'202605060611001504',24,3,15.4,1.0,3.0,19.4,2,'XX大学学生公寓1栋448室','不要香菜','2026-05-06 06:11:00','2026-05-06 06:16:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (67,'202603290530007391',18,4,180.9,1.0,3.0,184.9,6,'XX大学桃园宿舍132室','尽快配送','2026-03-29 05:30:00','2026-03-29 05:35:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (68,'202603231357003603',26,9,139.8,1.0,0.0,140.8,5,'XX大学体育馆428室','少冰','2026-03-23 13:57:00','2026-03-23 13:58:00','2026-03-23 15:03:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (69,'202604021138007550',29,5,178.3,1.0,5.0,184.3,4,'XX大学体育馆471室','不要辣','2026-04-02 11:38:00','2026-04-02 11:39:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (70,'202601271723009837',17,1,87.3,1.0,2.0,90.3,6,'XX大学学生公寓1栋354室','','2026-01-27 17:23:00','2026-01-27 17:28:00',NULL);
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (71,'202604191447008291',27,12,40.2,1.0,2.0,43.2,5,'XX大学行政楼172室','餐具一份','2026-04-19 14:47:00','2026-04-19 14:48:00','2026-04-19 15:48:00');
INSERT INTO orders(id,order_no,user_id,shop_id,goods_amount,pack_fee,delivery_fee,total_amount,status,address_snapshot,remark,create_time,pay_time,finish_time) VALUES (72,'202601092253006203',29,2,161.7,1.0,3.0,165.7,2,'XX大学桃园宿舍268室','少冰','2026-01-09 22:53:00','2026-01-09 22:58:00',NULL);

-- 为配送中(4)与已完成(5)的订单分配配送员，按订单号轮流分给 5 名骑手(id 32-36)；
-- 待配送(3)订单保持 rider_id 为空，留作骑手「抢单大厅」演示。
UPDATE orders SET rider_id = 32 + (id % 5) WHERE status IN (4, 5);

-- 订单明细
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (1,1,26,'炸酱面','uploads/dish/d_4_6.jpg',28.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (2,1,27,'热干面','uploads/dish/d_4_7.jpg',14.1,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (3,2,11,'招牌奶绿','uploads/dish/d_2_5.jpg',22.2,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (4,2,9,'芝芝莓莓','uploads/dish/d_2_3.jpg',12.7,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (5,2,12,'黑糖波波','uploads/dish/d_2_6.jpg',23.4,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (6,2,7,'珍珠奶茶','uploads/dish/d_2_1.jpg',10.3,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (7,3,56,'水果酸奶碗','uploads/dish/d_8_5.jpg',9.1,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (8,3,53,'牛油果沙拉','uploads/dish/d_8_2.jpg',24.1,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (9,3,59,'低脂能量碗','uploads/dish/d_8_8.jpg',36.8,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (10,4,51,'南瓜粥','uploads/dish/d_7_7.jpg',37.4,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (11,4,49,'蒸饺(8个)','uploads/dish/d_7_5.jpg',28.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (12,4,47,'豆浆油条','uploads/dish/d_7_3.jpg',14.2,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (13,5,69,'杨枝甘露','uploads/dish/d_2_2.jpg',8.7,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (14,6,40,'巧克力慕斯','uploads/dish/d_6_4.jpg',14.9,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (15,6,44,'红豆双皮奶','uploads/dish/d_6_8.jpg',10.8,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (16,6,39,'草莓蛋糕','uploads/dish/d_6_3.jpg',18.0,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (17,7,51,'南瓜粥','uploads/dish/d_7_7.jpg',37.4,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (18,7,46,'小笼包(6个)','uploads/dish/d_7_2.jpg',17.1,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (19,7,49,'蒸饺(8个)','uploads/dish/d_7_5.jpg',28.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (20,7,47,'豆浆油条','uploads/dish/d_7_3.jpg',14.2,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (21,8,41,'蛋挞(2个)','uploads/dish/d_6_5.jpg',10.6,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (22,8,42,'双皮奶','uploads/dish/d_6_6.jpg',8.7,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (23,8,43,'舒芙蕾','uploads/dish/d_6_7.jpg',34.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (24,8,37,'提拉米苏','uploads/dish/d_6_1.jpg',10.7,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (25,9,47,'豆浆油条','uploads/dish/d_7_3.jpg',14.2,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (26,9,51,'南瓜粥','uploads/dish/d_7_7.jpg',37.4,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (27,10,86,'烤茄子','uploads/dish/d_5_5.jpg',13.4,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (28,10,89,'麻辣小龙虾','uploads/dish/d_5_8.jpg',10.2,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (29,10,82,'烤羊肉串(10串)','uploads/dish/d_5_1.jpg',30.1,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (30,10,84,'烤韭菜','uploads/dish/d_5_3.jpg',30.9,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (31,11,24,'番茄鸡蛋面','uploads/dish/d_4_4.jpg',8.2,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (32,11,28,'鸭血粉丝汤','uploads/dish/d_4_8.jpg',21.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (33,11,25,'螺蛳粉','uploads/dish/d_4_5.jpg',22.4,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (34,11,23,'重庆小面','uploads/dish/d_4_3.jpg',20.6,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (35,12,78,'螺蛳粉','uploads/dish/d_4_5.jpg',33.4,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (36,12,74,'牛肉拉面','uploads/dish/d_4_1.jpg',9.1,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (37,13,26,'炸酱面','uploads/dish/d_4_6.jpg',28.0,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (38,13,28,'鸭血粉丝汤','uploads/dish/d_4_8.jpg',21.0,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (39,13,24,'番茄鸡蛋面','uploads/dish/d_4_4.jpg',8.2,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (40,13,23,'重庆小面','uploads/dish/d_4_3.jpg',20.6,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (41,14,38,'芒果千层','uploads/dish/d_6_2.jpg',27.5,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (42,15,49,'蒸饺(8个)','uploads/dish/d_7_5.jpg',28.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (43,15,48,'鲜肉包','uploads/dish/d_7_4.jpg',34.5,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (44,15,46,'小笼包(6个)','uploads/dish/d_7_2.jpg',17.1,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (45,16,1,'香辣鸡腿堡','uploads/dish/d_1_1.jpg',19.5,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (46,16,6,'可乐鸡翅','uploads/dish/d_1_6.jpg',25.9,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (47,16,2,'黄金鸡块','uploads/dish/d_1_2.jpg',13.2,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (48,16,5,'照烧鸡腿堡','uploads/dish/d_1_5.jpg',9.3,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (49,17,33,'烤茄子','uploads/dish/d_5_5.jpg',18.5,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (50,17,30,'烤鸡翅','uploads/dish/d_5_2.jpg',24.8,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (51,17,29,'烤羊肉串(10串)','uploads/dish/d_5_1.jpg',24.0,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (52,18,74,'牛肉拉面','uploads/dish/d_4_1.jpg',9.1,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (53,18,75,'酸辣粉','uploads/dish/d_4_2.jpg',22.7,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (54,18,77,'番茄鸡蛋面','uploads/dish/d_4_4.jpg',24.6,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (55,19,37,'提拉米苏','uploads/dish/d_6_1.jpg',10.7,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (56,20,64,'照烧鸡腿堡','uploads/dish/d_1_5.jpg',29.9,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (57,20,61,'黄金鸡块','uploads/dish/d_1_2.jpg',36.0,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (58,21,6,'可乐鸡翅','uploads/dish/d_1_6.jpg',25.9,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (59,22,41,'蛋挞(2个)','uploads/dish/d_6_5.jpg',10.6,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (60,22,40,'巧克力慕斯','uploads/dish/d_6_4.jpg',14.9,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (61,22,43,'舒芙蕾','uploads/dish/d_6_7.jpg',34.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (62,23,21,'牛肉拉面','uploads/dish/d_4_1.jpg',29.5,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (63,23,23,'重庆小面','uploads/dish/d_4_3.jpg',20.6,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (64,23,26,'炸酱面','uploads/dish/d_4_6.jpg',28.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (65,24,9,'芝芝莓莓','uploads/dish/d_2_3.jpg',12.7,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (66,24,11,'招牌奶绿','uploads/dish/d_2_5.jpg',22.2,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (67,24,10,'百香果茶','uploads/dish/d_2_4.jpg',25.7,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (68,25,82,'烤羊肉串(10串)','uploads/dish/d_5_1.jpg',30.1,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (69,25,83,'烤鸡翅','uploads/dish/d_5_2.jpg',22.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (70,25,88,'烤玉米','uploads/dish/d_5_7.jpg',31.8,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (71,26,29,'烤羊肉串(10串)','uploads/dish/d_5_1.jpg',24.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (72,26,36,'麻辣小龙虾','uploads/dish/d_5_8.jpg',27.7,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (73,26,31,'烤韭菜','uploads/dish/d_5_3.jpg',31.3,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (74,27,59,'低脂能量碗','uploads/dish/d_8_8.jpg',36.8,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (75,27,52,'鸡胸肉沙拉','uploads/dish/d_8_1.jpg',31.9,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (76,27,56,'水果酸奶碗','uploads/dish/d_8_5.jpg',9.1,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (77,28,41,'蛋挞(2个)','uploads/dish/d_6_5.jpg',10.6,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (78,28,37,'提拉米苏','uploads/dish/d_6_1.jpg',10.7,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (79,28,40,'巧克力慕斯','uploads/dish/d_6_4.jpg',14.9,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (80,28,39,'草莓蛋糕','uploads/dish/d_6_3.jpg',18.0,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (81,29,74,'牛肉拉面','uploads/dish/d_4_1.jpg',9.1,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (82,29,77,'番茄鸡蛋面','uploads/dish/d_4_4.jpg',24.6,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (83,29,76,'重庆小面','uploads/dish/d_4_3.jpg',20.7,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (84,29,79,'炸酱面','uploads/dish/d_4_6.jpg',10.1,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (85,30,58,'缤纷蔬菜杯','uploads/dish/d_8_7.jpg',33.3,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (86,31,86,'烤茄子','uploads/dish/d_5_5.jpg',13.4,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (87,31,83,'烤鸡翅','uploads/dish/d_5_2.jpg',22.0,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (88,31,89,'麻辣小龙虾','uploads/dish/d_5_8.jpg',10.2,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (89,31,87,'烤五花肉','uploads/dish/d_5_6.jpg',12.5,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (90,32,71,'百香果茶','uploads/dish/d_2_4.jpg',35.7,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (91,33,7,'珍珠奶茶','uploads/dish/d_2_1.jpg',10.3,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (92,33,11,'招牌奶绿','uploads/dish/d_2_5.jpg',22.2,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (93,33,10,'百香果茶','uploads/dish/d_2_4.jpg',25.7,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (94,34,71,'百香果茶','uploads/dish/d_2_4.jpg',35.7,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (95,35,54,'藜麦缤纷沙拉','uploads/dish/d_8_3.jpg',37.9,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (96,35,56,'水果酸奶碗','uploads/dish/d_8_5.jpg',9.1,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (97,35,52,'鸡胸肉沙拉','uploads/dish/d_8_1.jpg',31.9,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (98,36,74,'牛肉拉面','uploads/dish/d_4_1.jpg',9.1,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (99,36,78,'螺蛳粉','uploads/dish/d_4_5.jpg',33.4,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (100,36,79,'炸酱面','uploads/dish/d_4_6.jpg',10.1,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (101,37,60,'香辣鸡腿堡','uploads/dish/d_1_1.jpg',10.2,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (102,37,64,'照烧鸡腿堡','uploads/dish/d_1_5.jpg',29.9,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (103,37,63,'劲脆鸡排饭','uploads/dish/d_1_4.jpg',24.8,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (104,37,62,'薯条(大)','uploads/dish/d_1_3.jpg',22.2,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (105,38,40,'巧克力慕斯','uploads/dish/d_6_4.jpg',14.9,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (106,38,42,'双皮奶','uploads/dish/d_6_6.jpg',8.7,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (107,39,25,'螺蛳粉','uploads/dish/d_4_5.jpg',22.4,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (108,40,46,'小笼包(6个)','uploads/dish/d_7_2.jpg',17.1,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (109,40,50,'煎蛋三明治','uploads/dish/d_7_6.jpg',14.7,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (110,40,45,'皮蛋瘦肉粥','uploads/dish/d_7_1.jpg',30.1,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (111,40,48,'鲜肉包','uploads/dish/d_7_4.jpg',34.5,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (112,41,20,'咖喱鸡饭','uploads/dish/d_3_8.jpg',28.2,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (113,41,16,'土豆牛肉饭','uploads/dish/d_3_4.jpg',9.6,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (114,41,13,'黄焖鸡米饭','uploads/dish/d_3_1.jpg',14.8,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (115,42,32,'烤金针菇','uploads/dish/d_5_4.jpg',23.7,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (116,42,30,'烤鸡翅','uploads/dish/d_5_2.jpg',24.8,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (117,42,36,'麻辣小龙虾','uploads/dish/d_5_8.jpg',27.7,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (118,42,31,'烤韭菜','uploads/dish/d_5_3.jpg',31.3,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (119,43,61,'黄金鸡块','uploads/dish/d_1_2.jpg',36.0,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (120,43,64,'照烧鸡腿堡','uploads/dish/d_1_5.jpg',29.9,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (121,43,60,'香辣鸡腿堡','uploads/dish/d_1_1.jpg',10.2,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (122,44,17,'鱼香肉丝饭','uploads/dish/d_3_5.jpg',32.9,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (123,44,13,'黄焖鸡米饭','uploads/dish/d_3_1.jpg',14.8,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (124,44,16,'土豆牛肉饭','uploads/dish/d_3_4.jpg',9.6,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (125,45,27,'热干面','uploads/dish/d_4_7.jpg',14.1,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (126,45,25,'螺蛳粉','uploads/dish/d_4_5.jpg',22.4,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (127,45,22,'酸辣粉','uploads/dish/d_4_2.jpg',11.4,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (128,45,28,'鸭血粉丝汤','uploads/dish/d_4_8.jpg',21.0,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (129,46,26,'炸酱面','uploads/dish/d_4_6.jpg',28.0,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (130,47,70,'芝芝莓莓','uploads/dish/d_2_3.jpg',30.7,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (131,47,71,'百香果茶','uploads/dish/d_2_4.jpg',35.7,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (132,48,39,'草莓蛋糕','uploads/dish/d_6_3.jpg',18.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (133,48,42,'双皮奶','uploads/dish/d_6_6.jpg',8.7,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (134,48,44,'红豆双皮奶','uploads/dish/d_6_8.jpg',10.8,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (135,48,38,'芒果千层','uploads/dish/d_6_2.jpg',27.5,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (136,49,60,'香辣鸡腿堡','uploads/dish/d_1_1.jpg',10.2,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (137,49,61,'黄金鸡块','uploads/dish/d_1_2.jpg',36.0,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (138,50,48,'鲜肉包','uploads/dish/d_7_4.jpg',34.5,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (139,51,6,'可乐鸡翅','uploads/dish/d_1_6.jpg',25.9,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (140,51,3,'薯条(大)','uploads/dish/d_1_3.jpg',28.7,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (141,51,4,'劲脆鸡排饭','uploads/dish/d_1_4.jpg',32.2,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (142,51,1,'香辣鸡腿堡','uploads/dish/d_1_1.jpg',19.5,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (143,52,4,'劲脆鸡排饭','uploads/dish/d_1_4.jpg',32.2,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (144,53,52,'鸡胸肉沙拉','uploads/dish/d_8_1.jpg',31.9,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (145,53,58,'缤纷蔬菜杯','uploads/dish/d_8_7.jpg',33.3,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (146,53,57,'全麦鸡蛋卷','uploads/dish/d_8_6.jpg',36.0,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (147,53,55,'金枪鱼沙拉','uploads/dish/d_8_4.jpg',14.1,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (148,54,42,'双皮奶','uploads/dish/d_6_6.jpg',8.7,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (149,54,39,'草莓蛋糕','uploads/dish/d_6_3.jpg',18.0,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (150,54,43,'舒芙蕾','uploads/dish/d_6_7.jpg',34.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (151,55,86,'烤茄子','uploads/dish/d_5_5.jpg',13.4,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (152,55,89,'麻辣小龙虾','uploads/dish/d_5_8.jpg',10.2,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (153,55,84,'烤韭菜','uploads/dish/d_5_3.jpg',30.9,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (154,55,87,'烤五花肉','uploads/dish/d_5_6.jpg',12.5,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (155,56,64,'照烧鸡腿堡','uploads/dish/d_1_5.jpg',29.9,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (156,56,65,'可乐鸡翅','uploads/dish/d_1_6.jpg',19.2,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (157,56,67,'原味炸鸡','uploads/dish/d_1_8.jpg',13.8,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (158,57,53,'牛油果沙拉','uploads/dish/d_8_2.jpg',24.1,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (159,57,52,'鸡胸肉沙拉','uploads/dish/d_8_1.jpg',31.9,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (160,57,55,'金枪鱼沙拉','uploads/dish/d_8_4.jpg',14.1,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (161,57,57,'全麦鸡蛋卷','uploads/dish/d_8_6.jpg',36.0,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (162,58,21,'牛肉拉面','uploads/dish/d_4_1.jpg',29.5,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (163,58,27,'热干面','uploads/dish/d_4_7.jpg',14.1,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (164,59,73,'黑糖波波','uploads/dish/d_2_6.jpg',20.7,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (165,59,72,'招牌奶绿','uploads/dish/d_2_5.jpg',11.1,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (166,59,69,'杨枝甘露','uploads/dish/d_2_2.jpg',8.7,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (167,60,83,'烤鸡翅','uploads/dish/d_5_2.jpg',22.0,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (168,61,17,'鱼香肉丝饭','uploads/dish/d_3_5.jpg',32.9,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (169,62,14,'宫保鸡丁饭','uploads/dish/d_3_2.jpg',34.0,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (170,63,77,'番茄鸡蛋面','uploads/dish/d_4_4.jpg',24.6,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (171,63,80,'热干面','uploads/dish/d_4_7.jpg',30.7,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (172,63,76,'重庆小面','uploads/dish/d_4_3.jpg',20.7,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (173,64,39,'草莓蛋糕','uploads/dish/d_6_3.jpg',18.0,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (174,64,37,'提拉米苏','uploads/dish/d_6_1.jpg',10.7,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (175,64,38,'芒果千层','uploads/dish/d_6_2.jpg',27.5,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (176,65,31,'烤韭菜','uploads/dish/d_5_3.jpg',31.3,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (177,65,32,'烤金针菇','uploads/dish/d_5_4.jpg',23.7,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (178,65,34,'烤五花肉','uploads/dish/d_5_6.jpg',20.7,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (179,65,29,'烤羊肉串(10串)','uploads/dish/d_5_1.jpg',24.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (180,66,15,'红烧肉盖饭','uploads/dish/d_3_3.jpg',15.4,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (181,67,28,'鸭血粉丝汤','uploads/dish/d_4_8.jpg',21.0,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (182,67,26,'炸酱面','uploads/dish/d_4_6.jpg',28.0,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (183,67,25,'螺蛳粉','uploads/dish/d_4_5.jpg',22.4,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (184,67,21,'牛肉拉面','uploads/dish/d_4_1.jpg',29.5,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (185,68,62,'薯条(大)','uploads/dish/d_1_3.jpg',22.2,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (186,68,65,'可乐鸡翅','uploads/dish/d_1_6.jpg',19.2,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (187,68,66,'牛肉汉堡','uploads/dish/d_1_7.jpg',12.6,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (188,69,29,'烤羊肉串(10串)','uploads/dish/d_5_1.jpg',24.0,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (189,69,36,'麻辣小龙虾','uploads/dish/d_5_8.jpg',27.7,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (190,69,35,'烤玉米','uploads/dish/d_5_7.jpg',26.9,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (191,69,30,'烤鸡翅','uploads/dish/d_5_2.jpg',24.8,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (192,70,4,'劲脆鸡排饭','uploads/dish/d_1_4.jpg',32.2,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (193,70,2,'黄金鸡块','uploads/dish/d_1_2.jpg',13.2,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (194,70,3,'薯条(大)','uploads/dish/d_1_3.jpg',28.7,1);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (195,71,86,'烤茄子','uploads/dish/d_5_5.jpg',13.4,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (196,72,11,'招牌奶绿','uploads/dish/d_2_5.jpg',22.2,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (197,72,10,'百香果茶','uploads/dish/d_2_4.jpg',25.7,2);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (198,72,9,'芝芝莓莓','uploads/dish/d_2_3.jpg',12.7,3);
INSERT INTO order_item(id,order_id,dish_id,dish_name,dish_image,price,quantity) VALUES (199,72,8,'杨枝甘露','uploads/dish/d_2_2.jpg',13.9,2);

-- 评价
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (1,2,19,2,3,'口味一般，可以接受','','谢谢您的好评，我们会继续努力~','2026-05-08 12:37:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (2,3,24,8,4,'配送有点慢，味道还行','','','2026-02-07 06:48:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (3,7,17,7,3,'口味一般，可以接受','','感谢支持，欢迎再次光临！','2026-04-28 01:27:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (4,8,21,6,5,'味道不错，分量足，下次还来！','','','2026-02-17 21:03:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (5,16,19,1,5,'非常好吃，已经回购啦','','感谢反馈，我们会改进配送速度','2026-02-15 09:05:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (6,21,29,1,3,'送餐很快，包装也好','','感谢支持，欢迎再次光临！','2026-02-24 23:13:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (7,22,20,6,4,'学生党福音，便宜量大','','','2026-06-05 01:40:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (8,25,25,12,3,'口味一般，可以接受','','','2026-03-01 05:29:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (9,29,21,11,3,'包装精致，味道惊艳','','','2026-06-12 20:00:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (10,31,21,12,4,'非常好吃，已经回购啦','','','2026-05-07 21:47:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (11,32,24,10,3,'学生党福音，便宜量大','','谢谢您的好评，我们会继续努力~','2026-04-09 21:40:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (12,38,20,6,3,'包装精致，味道惊艳','','感谢支持，欢迎再次光临！','2026-01-05 12:58:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (13,41,30,3,5,'学生党福音，便宜量大','','谢谢您的好评，我们会继续努力~','2026-04-18 20:06:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (14,42,26,5,5,'非常好吃，已经回购啦','','','2026-01-09 08:25:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (15,48,21,6,3,'学生党福音，便宜量大','','','2025-12-27 14:29:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (16,51,22,1,5,'性价比很高，推荐','','','2026-03-21 21:56:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (17,54,27,6,4,'包装精致，味道惊艳','','谢谢您的好评，我们会继续努力~','2026-04-17 02:03:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (18,55,26,12,4,'配送有点慢，味道还行','','感谢反馈，我们会改进配送速度','2026-03-24 15:46:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (19,63,21,11,3,'味道不错，分量足，下次还来！','','感谢支持，欢迎再次光临！','2026-03-13 05:28:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (20,65,19,5,5,'性价比很高，推荐','','','2026-05-04 02:57:00');
INSERT INTO review(id,order_id,user_id,shop_id,rating,content,images,reply,create_time) VALUES (21,68,26,9,4,'学生党福音，便宜量大','','感谢反馈，我们会改进配送速度','2026-03-24 09:57:00');

-- 公告
INSERT INTO notice(id,title,content,create_time) VALUES (1,'平台上线公告','校园外卖平台正式上线，欢迎广大师生使用，足不出户享受美食！','2026-06-11 06:10:00');
INSERT INTO notice(id,title,content,create_time) VALUES (2,'配送时间调整','因近期天气原因，部分时段配送时间延长，请大家耐心等待。','2026-03-22 16:46:00');
INSERT INTO notice(id,title,content,create_time) VALUES (3,'新商家入驻','本周新增多家优质商户，更多美味等你来发现。','2026-03-23 03:48:00');
INSERT INTO notice(id,title,content,create_time) VALUES (4,'评价有奖活动','完成订单并评价，即有机会获得平台优惠券。','2026-03-27 01:26:00');
INSERT INTO notice(id,title,content,create_time) VALUES (5,'文明用餐倡议','请大家节约粮食，按需点餐，共建文明校园。','2026-02-21 09:35:00');
INSERT INTO notice(id,title,content,create_time) VALUES (6,'客服服务时间','平台客服服务时间为每日 8:00-22:00，如有问题请及时反馈。','2026-05-09 09:45:00');

-- ============ 配送费修复：免配送费(≤0)店铺统一按默认 3 元计，保证骑手每单有收入 ============
UPDATE shop SET delivery_fee = 3 WHERE delivery_fee IS NULL OR delivery_fee <= 0;
-- 历史订单同步补差价：商品+包装+配送=实付，明细自洽
UPDATE orders SET total_amount = total_amount + 3, delivery_fee = 3 WHERE delivery_fee IS NULL OR delivery_fee <= 0;

-- ============ 配送时效回填：已有订单补 accept_time / sla_deadline ============
-- 已完成(5)：接单时间取支付时间，截止 = 支付时间 + 60 分钟
UPDATE orders SET accept_time = pay_time, sla_deadline = DATE_ADD(pay_time, INTERVAL 60 MINUTE)
  WHERE status = 5 AND pay_time IS NOT NULL;
-- 配送中(4)：以当前时间为接单点，截止 = 现在 + 50 分钟，便于倒计时演示
UPDATE orders SET accept_time = NOW(), sla_deadline = DATE_ADD(NOW(), INTERVAL 50 MINUTE)
  WHERE status = 4;
-- 待配送(3)：尚未抢单，截止 = 现在 + 60 分钟
UPDATE orders SET accept_time = NOW(), sla_deadline = DATE_ADD(NOW(), INTERVAL 60 MINUTE)
  WHERE status = 3;
