package com.campus.takeout.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.takeout.entity.*;
import com.campus.takeout.mapper.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 工作台统计服务：按登录角色返回不同的统计数据，
 * 管理员看全局、商家看本店、用户看个人，统计在服务端按角色过滤。
 */
@Service
public class StatsService {

    @Autowired
    private UserMapper userMapper;
    @Autowired
    private ShopMapper shopMapper;
    @Autowired
    private DishMapper dishMapper;
    @Autowired
    private OrdersMapper ordersMapper;
    @Autowired
    private ShopCategoryMapper categoryMapper;

    /** 生成近 6 个月的月份标签，如 2026-01 ... 2026-06 */
    private List<String> last6Months() {
        List<String> months = new ArrayList<>();
        YearMonth cur = YearMonth.now();
        for (int i = 5; i >= 0; i--) {
            months.add(cur.minusMonths(i).format(DateTimeFormatter.ofPattern("yyyy-MM")));
        }
        return months;
    }

    private String ym(LocalDateTime t) {
        return t.format(DateTimeFormatter.ofPattern("yyyy-MM"));
    }

    /** 管理员工作台：平台全局统计 */
    public Map<String, Object> adminStats() {
        Map<String, Object> r = new HashMap<>();
        r.put("userCount", userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getRole, "USER")));
        r.put("shopCount", shopMapper.selectCount(null));
        List<Orders> orders = ordersMapper.selectList(null);
        r.put("orderCount", orders.size());
        // 总营收：已完成订单实付金额
        BigDecimal revenue = orders.stream()
                .filter(o -> o.getStatus() == 5)
                .map(Orders::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        r.put("revenue", revenue);
        r.put("pendingShop", shopMapper.selectCount(new LambdaQueryWrapper<Shop>().eq(Shop::getStatus, 0)));

        // 近 6 月营收趋势
        List<String> months = last6Months();
        Map<String, BigDecimal> revMap = new LinkedHashMap<>();
        Map<String, Integer> cntMap = new LinkedHashMap<>();
        for (String m : months) {
            revMap.put(m, BigDecimal.ZERO);
            cntMap.put(m, 0);
        }
        for (Orders o : orders) {
            String m = ym(o.getCreateTime());
            if (cntMap.containsKey(m)) {
                cntMap.put(m, cntMap.get(m) + 1);
                if (o.getStatus() == 5) {
                    revMap.put(m, revMap.get(m).add(o.getTotalAmount()));
                }
            }
        }
        r.put("months", months);
        r.put("revenueTrend", new ArrayList<>(revMap.values()));
        r.put("orderTrend", new ArrayList<>(cntMap.values()));

        // 订单状态分布（饼图）
        int[] statusCnt = new int[7];
        for (Orders o : orders) {
            if (o.getStatus() >= 1 && o.getStatus() <= 6) {
                statusCnt[o.getStatus()]++;
            }
        }
        String[] statusName = {"", "待支付", "待接单", "待配送", "配送中", "已完成", "已取消"};
        List<Map<String, Object>> statusDist = new ArrayList<>();
        for (int i = 1; i <= 6; i++) {
            Map<String, Object> item = new HashMap<>();
            item.put("name", statusName[i]);
            item.put("value", statusCnt[i]);
            statusDist.add(item);
        }
        r.put("statusDist", statusDist);

        // 店铺分类分布（柱图）
        List<ShopCategory> cats = categoryMapper.selectList(null);
        List<Shop> shops = shopMapper.selectList(null);
        List<String> catNames = new ArrayList<>();
        List<Long> catValues = new ArrayList<>();
        for (ShopCategory c : cats) {
            catNames.add(c.getName());
            long cnt = shops.stream().filter(s -> c.getId().equals(s.getCategoryId())).count();
            catValues.add(cnt);
        }
        r.put("catNames", catNames);
        r.put("catValues", catValues);
        return r;
    }

    /** 商家工作台：本店统计 */
    public Map<String, Object> merchantStats(Long ownerId) {
        Map<String, Object> r = new HashMap<>();
        Shop shop = shopMapper.selectOne(new LambdaQueryWrapper<Shop>()
                .eq(Shop::getOwnerId, ownerId).last("limit 1"));
        if (shop == null) {
            r.put("hasShop", false);
            return r;
        }
        r.put("hasShop", true);
        r.put("shopName", shop.getName());
        List<Orders> orders = ordersMapper.selectList(new LambdaQueryWrapper<Orders>()
                .eq(Orders::getShopId, shop.getId()));
        LocalDate today = LocalDate.now();
        BigDecimal todayRevenue = BigDecimal.ZERO;
        BigDecimal monthRevenue = BigDecimal.ZERO;
        int pending = 0;
        YearMonth curMonth = YearMonth.now();
        for (Orders o : orders) {
            if (o.getStatus() == 5) {
                if (o.getCreateTime().toLocalDate().equals(today)) {
                    todayRevenue = todayRevenue.add(o.getTotalAmount());
                }
                if (YearMonth.from(o.getCreateTime()).equals(curMonth)) {
                    monthRevenue = monthRevenue.add(o.getTotalAmount());
                }
            }
            if (o.getStatus() == 2) {
                pending++;
            }
        }
        r.put("todayRevenue", todayRevenue);
        r.put("monthRevenue", monthRevenue);
        r.put("orderCount", orders.size());
        r.put("pendingOrder", pending);
        r.put("dishCount", dishMapper.selectCount(new LambdaQueryWrapper<Dish>()
                .eq(Dish::getShopId, shop.getId())));

        // 近 6 月营业额趋势
        List<String> months = last6Months();
        Map<String, BigDecimal> revMap = new LinkedHashMap<>();
        for (String m : months) {
            revMap.put(m, BigDecimal.ZERO);
        }
        for (Orders o : orders) {
            String m = ym(o.getCreateTime());
            if (revMap.containsKey(m) && o.getStatus() == 5) {
                revMap.put(m, revMap.get(m).add(o.getTotalAmount()));
            }
        }
        r.put("months", months);
        r.put("revenueTrend", new ArrayList<>(revMap.values()));

        // 热销菜品 Top5（饼图）
        List<Dish> dishes = dishMapper.selectList(new LambdaQueryWrapper<Dish>()
                .eq(Dish::getShopId, shop.getId())
                .orderByDesc(Dish::getSales).last("limit 5"));
        List<Map<String, Object>> topDishes = new ArrayList<>();
        for (Dish d : dishes) {
            Map<String, Object> item = new HashMap<>();
            item.put("name", d.getName());
            item.put("value", d.getSales() == null ? 0 : d.getSales());
            topDishes.add(item);
        }
        r.put("topDishes", topDishes);
        return r;
    }

    /** 用户工作台：个人消费统计 */
    public Map<String, Object> userStats(Long userId) {
        Map<String, Object> r = new HashMap<>();
        List<Orders> orders = ordersMapper.selectList(new LambdaQueryWrapper<Orders>()
                .eq(Orders::getUserId, userId));
        r.put("orderCount", orders.size());
        long finished = orders.stream().filter(o -> o.getStatus() == 5).count();
        long ongoing = orders.stream().filter(o -> o.getStatus() >= 2 && o.getStatus() <= 4).count();
        r.put("finishedCount", finished);
        r.put("ongoingCount", ongoing);
        BigDecimal totalSpent = orders.stream()
                .filter(o -> o.getStatus() == 5)
                .map(Orders::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        r.put("totalSpent", totalSpent);

        List<String> months = last6Months();
        Map<String, BigDecimal> spentMap = new LinkedHashMap<>();
        for (String m : months) {
            spentMap.put(m, BigDecimal.ZERO);
        }
        for (Orders o : orders) {
            String m = ym(o.getCreateTime());
            if (spentMap.containsKey(m) && o.getStatus() == 5) {
                spentMap.put(m, spentMap.get(m).add(o.getTotalAmount()));
            }
        }
        r.put("months", months);
        r.put("spentTrend", new ArrayList<>(spentMap.values()));
        return r;
    }

    /** 配送员工作台：本骑手的配送统计（待抢单数为全平台可抢量，其余按本人过滤） */
    public Map<String, Object> riderStats(Long riderId) {
        Map<String, Object> r = new HashMap<>();
        // 抢单大厅可抢数量：待配送且未分配骑手
        Long available = ordersMapper.selectCount(new LambdaQueryWrapper<Orders>()
                .eq(Orders::getStatus, 3).isNull(Orders::getRiderId));
        r.put("availableCount", available);

        List<Orders> mine = ordersMapper.selectList(new LambdaQueryWrapper<Orders>()
                .eq(Orders::getRiderId, riderId));
        long delivering = mine.stream().filter(o -> o.getStatus() == 4).count();
        long finished = mine.stream().filter(o -> o.getStatus() == 5).count();
        r.put("deliveringCount", delivering);
        r.put("finishedCount", finished);

        // 今日完成单数与配送费收入（以配送费计为骑手收入口径，便于演示）
        LocalDate today = LocalDate.now();
        long todayFinished = mine.stream()
                .filter(o -> o.getStatus() == 5 && o.getFinishTime() != null
                        && o.getFinishTime().toLocalDate().equals(today))
                .count();
        r.put("todayFinished", todayFinished);
        BigDecimal income = mine.stream()
                .filter(o -> o.getStatus() == 5)
                .map(o -> o.getDeliveryFee() == null ? BigDecimal.ZERO : o.getDeliveryFee())
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        r.put("income", income);

        // 近 6 月完成单量趋势
        List<String> months = last6Months();
        Map<String, Integer> cntMap = new LinkedHashMap<>();
        for (String m : months) {
            cntMap.put(m, 0);
        }
        for (Orders o : mine) {
            if (o.getStatus() != 5 || o.getFinishTime() == null) {
                continue;
            }
            String m = ym(o.getFinishTime());
            if (cntMap.containsKey(m)) {
                cntMap.put(m, cntMap.get(m) + 1);
            }
        }
        r.put("months", months);
        r.put("finishTrend", new ArrayList<>(cntMap.values()));
        return r;
    }
}
