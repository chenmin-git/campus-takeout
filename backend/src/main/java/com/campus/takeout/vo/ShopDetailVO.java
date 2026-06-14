package com.campus.takeout.vo;

import com.campus.takeout.entity.Dish;
import com.campus.takeout.entity.Shop;
import lombok.Data;

import java.util.List;

/**
 * 店铺详情视图：店铺基本信息 + 在售菜品列表。
 */
@Data
public class ShopDetailVO {
    private Shop shop;
    private List<Dish> dishes;
    private String categoryName;
}
