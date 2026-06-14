package com.campus.takeout.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 店铺：归属某个商家用户（owner_id），需管理员审核后才能营业。
 */
@Data
@TableName("shop")
public class Shop {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    /** 店铺 logo（本地相对路径） */
    private String logo;
    /** 店铺封面图（本地相对路径） */
    private String cover;
    private String description;
    private Long categoryId;
    /** 所属商家用户 id */
    private Long ownerId;
    private String address;
    /** 店铺公告 */
    private String notice;
    /** 配送费 */
    private BigDecimal deliveryFee;
    /** 起送金额 */
    private BigDecimal minAmount;
    /** 评分 */
    private BigDecimal rating;
    /** 月销量 */
    private Integer sales;
    /** 状态：0 待审核 1 营业 2 停业 3 审核驳回 */
    private Integer status;
    private LocalDateTime createTime;

    @TableLogic
    private Integer deleted;
}
