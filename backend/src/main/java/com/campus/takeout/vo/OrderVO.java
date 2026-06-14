package com.campus.takeout.vo;

import com.campus.takeout.entity.OrderItem;
import com.campus.takeout.entity.Orders;
import lombok.Data;

import java.util.List;

/**
 * 订单视图：订单 + 明细 + 店铺名称 + 是否已评价，便于前端列表与详情展示。
 */
@Data
public class OrderVO {
    private Orders order;
    private List<OrderItem> items;
    private String shopName;
    private String shopLogo;
    private Boolean reviewed;
}
