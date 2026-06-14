package com.campus.takeout.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 订单评价：用户对已完成订单的店铺评分与文字，商家可回复。
 */
@Data
@TableName("review")
public class Review {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orderId;
    private Long userId;
    private Long shopId;
    /** 评分 1-5 */
    private Integer rating;
    private String content;
    /** 评价图片，多张以逗号分隔的本地相对路径 */
    private String images;
    /** 商家回复 */
    private String reply;
    private LocalDateTime createTime;

    @TableLogic
    private Integer deleted;
}
