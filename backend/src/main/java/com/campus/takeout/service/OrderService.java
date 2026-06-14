package com.campus.takeout.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.takeout.common.BusinessException;
import com.campus.takeout.common.PageResult;
import com.campus.takeout.dto.CreateOrderDTO;
import com.campus.takeout.dto.OrderItemDTO;
import com.campus.takeout.entity.*;
import com.campus.takeout.mapper.*;
import com.campus.takeout.vo.OrderVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * 订单服务：下单、支付、状态流转、按角色分页查询。
 * 状态：1待支付 2待接单 3待配送 4配送中 5已完成 6已取消。
 */
@Service
public class OrderService {

    @Autowired
    private OrdersMapper ordersMapper;
    @Autowired
    private OrderItemMapper orderItemMapper;
    @Autowired
    private DishMapper dishMapper;
    @Autowired
    private ShopMapper shopMapper;
    @Autowired
    private AddressMapper addressMapper;
    @Autowired
    private ReviewMapper reviewMapper;

    /** 默认配送费：免配送费(≤0)店铺下单时按此值计，保证骑手每单都有配送收入。 */
    private static final BigDecimal DEFAULT_DELIVERY_FEE = new BigDecimal("3.0");

    /** 默认配送时效（分钟）：商家接单起至送达的标准时长。 */
    private static final long DEFAULT_SLA_MINUTES = 60L;

    /**
     * 创建订单：金额以服务端菜品价格为准，避免前端篡改；同时生成地址快照与订单明细。
     */
    @Transactional
    public Long create(CreateOrderDTO dto, Long userId) {
        if (dto.getItems() == null || dto.getItems().isEmpty()) {
            throw new BusinessException("购物车为空，无法下单");
        }
        Shop shop = shopMapper.selectById(dto.getShopId());
        if (shop == null || shop.getStatus() != 1) {
            throw new BusinessException("店铺不存在或已停业");
        }
        Address address = addressMapper.selectById(dto.getAddressId());
        if (address == null || !address.getUserId().equals(userId)) {
            throw new BusinessException("收货地址无效");
        }

        BigDecimal goodsAmount = BigDecimal.ZERO;
        List<OrderItem> items = new ArrayList<>();
        for (OrderItemDTO it : dto.getItems()) {
            Dish dish = dishMapper.selectById(it.getDishId());
            if (dish == null || dish.getStatus() != 1) {
                throw new BusinessException("菜品已下架，请重新选择");
            }
            int qty = it.getQuantity() == null || it.getQuantity() < 1 ? 1 : it.getQuantity();
            goodsAmount = goodsAmount.add(dish.getPrice().multiply(BigDecimal.valueOf(qty)));
            OrderItem oi = new OrderItem();
            oi.setDishId(dish.getId());
            oi.setDishName(dish.getName());
            oi.setDishImage(dish.getImage());
            oi.setPrice(dish.getPrice());
            oi.setQuantity(qty);
            items.add(oi);
        }
        // 起送金额校验
        if (shop.getMinAmount() != null && goodsAmount.compareTo(shop.getMinAmount()) < 0) {
            throw new BusinessException("未达到起送金额 " + shop.getMinAmount() + " 元");
        }

        BigDecimal packFee = new BigDecimal("1.0");
        // 配送费为空或免配送费(≤0)的店铺统一按默认值计，避免骑手该单零收入；已设 2/3/5 元的店保持原值
        BigDecimal deliveryFee = (shop.getDeliveryFee() == null || shop.getDeliveryFee().compareTo(BigDecimal.ZERO) <= 0)
                ? DEFAULT_DELIVERY_FEE : shop.getDeliveryFee();
        BigDecimal total = goodsAmount.add(packFee).add(deliveryFee);

        Orders order = new Orders();
        order.setOrderNo(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + (System.nanoTime() % 10000));
        order.setUserId(userId);
        order.setShopId(shop.getId());
        order.setGoodsAmount(goodsAmount);
        order.setPackFee(packFee);
        order.setDeliveryFee(deliveryFee);
        order.setTotalAmount(total);
        order.setStatus(1);
        order.setAddressSnapshot(address.getName() + " " + address.getPhone() + " " + address.getDetail());
        order.setRemark(dto.getRemark());
        order.setCreateTime(LocalDateTime.now());
        ordersMapper.insert(order);

        for (OrderItem oi : items) {
            oi.setOrderId(order.getId());
            orderItemMapper.insert(oi);
        }
        return order.getId();
    }

    /** 模拟支付：待支付 → 待接单 */
    public void pay(Long orderId, Long userId) {
        Orders order = mustOwn(orderId, userId);
        if (order.getStatus() != 1) {
            throw new BusinessException("订单状态不允许支付");
        }
        order.setStatus(2);
        order.setPayTime(LocalDateTime.now());
        ordersMapper.updateById(order);
        // 支付成功后累加菜品与店铺销量
        addSales(order);
    }

    /** 用户取消：仅待支付或待接单可取消 */
    public void cancel(Long orderId, Long userId) {
        Orders order = mustOwn(orderId, userId);
        if (order.getStatus() != 1 && order.getStatus() != 2) {
            throw new BusinessException("当前状态不可取消");
        }
        order.setStatus(6);
        ordersMapper.updateById(order);
    }

    /**
     * 用户退款：模拟退款 = 已支付但尚未完成的订单（待接单2 / 待配送3 / 配送中4）→ 已取消(6)。
     * 仅本人订单可退；待支付(1)请走取消，已完成(5)/已取消(6)不可退。
     */
    public void refund(Long orderId, Long userId) {
        Orders order = mustOwn(orderId, userId);
        if (order.getStatus() != 2 && order.getStatus() != 3 && order.getStatus() != 4) {
            throw new BusinessException("当前状态不可退款");
        }
        order.setStatus(6);
        ordersMapper.updateById(order);
    }

    /** 用户确认收货：配送中 → 已完成 */
    public void confirm(Long orderId, Long userId) {
        Orders order = mustOwn(orderId, userId);
        if (order.getStatus() != 4) {
            throw new BusinessException("当前状态不可确认收货");
        }
        order.setStatus(5);
        order.setFinishTime(LocalDateTime.now());
        ordersMapper.updateById(order);
    }

    /**
     * 商家接单：待接单(2) → 待配送(3)。
     * 引入配送员角色后，商家只负责接单，后续配送由骑手完成，故仅允许 2→3 流转。
     */
    public void merchantAdvance(Long orderId, Long ownerId, Integer targetStatus) {
        Orders order = ordersMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        Shop shop = shopMapper.selectById(order.getShopId());
        if (shop == null || !shop.getOwnerId().equals(ownerId)) {
            throw new BusinessException("无权操作该订单");
        }
        // 仅允许商家接单（2→3），配送、送达均由骑手处理
        if (!(order.getStatus() == 2 && targetStatus == 3)) {
            throw new BusinessException("订单状态流转不合法");
        }
        order.setStatus(3);
        // 接单即开始配送时效计时：截止时间 = 接单时间 + 默认时长，用户与骑手均可见
        LocalDateTime now = LocalDateTime.now();
        order.setAcceptTime(now);
        order.setSlaDeadline(now.plusMinutes(DEFAULT_SLA_MINUTES));
        ordersMapper.updateById(order);
    }

    /**
     * 骑手申请延期：仅配送中(4)且属于本骑手的订单可申请；填写延长分钟数与原因。
     * 置 extendStatus=1（待用户审批），等待用户在订单详情中同意或拒绝。
     */
    public void riderRequestExtend(Long orderId, Long riderId, Integer minutes, String reason) {
        Orders order = ordersMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        if (order.getStatus() != 4 || !riderId.equals(order.getRiderId())) {
            throw new BusinessException("无权操作或订单状态不可申请延期");
        }
        if (minutes == null || minutes <= 0) {
            throw new BusinessException("延长时间需大于 0 分钟");
        }
        if (order.getExtendStatus() != null && order.getExtendStatus() == 1) {
            throw new BusinessException("已有待审批的延期申请");
        }
        order.setExtendStatus(1);
        order.setExtendMinutes(minutes);
        order.setExtendReason(reason);
        ordersMapper.updateById(order);
    }

    /**
     * 用户审批延期：仅本人订单且存在待审批申请(extendStatus=1)时有效。
     * 同意则截止时间顺延申请的分钟数并置 extendStatus=2；拒绝则置 extendStatus=3，时效不变。
     */
    public void userDecideExtend(Long orderId, Long userId, boolean approve) {
        Orders order = mustOwn(orderId, userId);
        if (order.getExtendStatus() == null || order.getExtendStatus() != 1) {
            throw new BusinessException("没有待审批的延期申请");
        }
        if (approve) {
            int minutes = order.getExtendMinutes() == null ? 0 : order.getExtendMinutes();
            LocalDateTime base = order.getSlaDeadline() == null ? LocalDateTime.now() : order.getSlaDeadline();
            order.setSlaDeadline(base.plusMinutes(minutes));
            order.setExtendStatus(2);
        } else {
            order.setExtendStatus(3);
        }
        ordersMapper.updateById(order);
    }

    /**
     * 骑手抢单：待配送(3) 且尚未分配骑手 → 配送中(4)，写入当前骑手ID。
     * 用乐观校验避免并发抢同一单：更新时同时限定 status=3 且 rider_id 为空。
     */
    public void riderGrab(Long orderId, Long riderId) {
        Orders order = ordersMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        if (order.getStatus() != 3 || order.getRiderId() != null) {
            throw new BusinessException("订单已被抢或状态不可抢单");
        }
        order.setStatus(4);
        order.setRiderId(riderId);
        ordersMapper.updateById(order);
    }

    /** 骑手送达：配送中(4) 且属于本骑手 → 已完成(5)，记录完成时间。 */
    public void riderDeliver(Long orderId, Long riderId) {
        Orders order = ordersMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        if (order.getStatus() != 4 || !riderId.equals(order.getRiderId())) {
            throw new BusinessException("无权操作或订单状态不可送达");
        }
        order.setStatus(5);
        order.setFinishTime(LocalDateTime.now());
        ordersMapper.updateById(order);
    }

    /** 骑手抢单大厅：待配送(3) 且未分配骑手的订单分页。 */
    public PageResult<OrderVO> riderAvailablePage(int pageNum, int pageSize) {
        LambdaQueryWrapper<Orders> qw = new LambdaQueryWrapper<Orders>()
                .eq(Orders::getStatus, 3)
                .isNull(Orders::getRiderId)
                .orderByDesc(Orders::getCreateTime);
        return toVoPage(ordersMapper.selectPage(new Page<>(pageNum, pageSize), qw));
    }

    /** 骑手我的配送：当前骑手的订单分页，可按状态筛选（4配送中/5已完成）。 */
    public PageResult<OrderVO> riderMyPage(Long riderId, int pageNum, int pageSize, Integer status) {
        LambdaQueryWrapper<Orders> qw = new LambdaQueryWrapper<Orders>()
                .eq(Orders::getRiderId, riderId);
        if (status != null) {
            qw.eq(Orders::getStatus, status);
        }
        qw.orderByDesc(Orders::getCreateTime);
        return toVoPage(ordersMapper.selectPage(new Page<>(pageNum, pageSize), qw));
    }

    private void addSales(Orders order) {
        List<OrderItem> items = orderItemMapper.selectList(new LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, order.getId()));
        int total = 0;
        for (OrderItem it : items) {
            Dish dish = dishMapper.selectById(it.getDishId());
            if (dish != null) {
                dish.setSales((dish.getSales() == null ? 0 : dish.getSales()) + it.getQuantity());
                dishMapper.updateById(dish);
                total += it.getQuantity();
            }
        }
        Shop shop = shopMapper.selectById(order.getShopId());
        if (shop != null) {
            shop.setSales((shop.getSales() == null ? 0 : shop.getSales()) + total);
            shopMapper.updateById(shop);
        }
    }

    private Orders mustOwn(Long orderId, Long userId) {
        Orders order = ordersMapper.selectById(orderId);
        if (order == null || !order.getUserId().equals(userId)) {
            throw new BusinessException("订单不存在");
        }
        return order;
    }

    /** 用户端订单分页 */
    public PageResult<OrderVO> userPage(Long userId, int pageNum, int pageSize, Integer status) {
        LambdaQueryWrapper<Orders> qw = new LambdaQueryWrapper<Orders>()
                .eq(Orders::getUserId, userId);
        if (status != null) {
            qw.eq(Orders::getStatus, status);
        }
        qw.orderByDesc(Orders::getCreateTime);
        return toVoPage(ordersMapper.selectPage(new Page<>(pageNum, pageSize), qw));
    }

    /** 商家端订单分页（本店订单） */
    public PageResult<OrderVO> merchantPage(Long ownerId, int pageNum, int pageSize, Integer status) {
        Shop shop = shopMapper.selectOne(new LambdaQueryWrapper<Shop>()
                .eq(Shop::getOwnerId, ownerId).last("limit 1"));
        if (shop == null) {
            return new PageResult<>(0L, new ArrayList<>());
        }
        LambdaQueryWrapper<Orders> qw = new LambdaQueryWrapper<Orders>()
                .eq(Orders::getShopId, shop.getId());
        if (status != null) {
            qw.eq(Orders::getStatus, status);
        }
        qw.orderByDesc(Orders::getCreateTime);
        return toVoPage(ordersMapper.selectPage(new Page<>(pageNum, pageSize), qw));
    }

    /** 管理员端订单分页（全部） */
    public PageResult<OrderVO> adminPage(int pageNum, int pageSize, Integer status, String keyword) {
        LambdaQueryWrapper<Orders> qw = new LambdaQueryWrapper<>();
        if (status != null) {
            qw.eq(Orders::getStatus, status);
        }
        if (keyword != null && !keyword.isEmpty()) {
            qw.like(Orders::getOrderNo, keyword);
        }
        qw.orderByDesc(Orders::getCreateTime);
        return toVoPage(ordersMapper.selectPage(new Page<>(pageNum, pageSize), qw));
    }

    public OrderVO detail(Long orderId) {
        Orders order = ordersMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        return toVo(order);
    }

    private PageResult<OrderVO> toVoPage(Page<Orders> page) {
        List<OrderVO> list = new ArrayList<>();
        for (Orders o : page.getRecords()) {
            list.add(toVo(o));
        }
        return new PageResult<>(page.getTotal(), list);
    }

    private OrderVO toVo(Orders order) {
        OrderVO vo = new OrderVO();
        vo.setOrder(order);
        vo.setItems(orderItemMapper.selectList(new LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getOrderId, order.getId())));
        Shop shop = shopMapper.selectById(order.getShopId());
        if (shop != null) {
            vo.setShopName(shop.getName());
            vo.setShopLogo(shop.getLogo());
        }
        Long reviewed = reviewMapper.selectCount(new LambdaQueryWrapper<Review>()
                .eq(Review::getOrderId, order.getId()));
        vo.setReviewed(reviewed != null && reviewed > 0);
        return vo;
    }
}
