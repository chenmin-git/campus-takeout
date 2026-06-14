package com.campus.takeout.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 菜品：归属某个店铺。
 */
@Data
@TableName("dish")
public class Dish {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long shopId;
    private String name;
    /** 菜品图片（本地相对路径） */
    private String image;
    private BigDecimal price;
    private String description;
    /** 店内分类：主食/小吃/饮品等 */
    private String dishCategory;
    private Integer sales;
    private Integer stock;
    /** 状态：1 上架 0 下架 */
    private Integer status;
    private LocalDateTime createTime;

    @TableLogic
    private Integer deleted;
}
