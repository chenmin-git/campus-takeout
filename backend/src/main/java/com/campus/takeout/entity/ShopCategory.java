package com.campus.takeout.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

/**
 * 店铺分类：快餐、奶茶、正餐、夜宵等。
 */
@Data
@TableName("shop_category")
public class ShopCategory {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    /** 分类图标（本地相对路径） */
    private String icon;
    private Integer sort;
}
