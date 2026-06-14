package com.campus.takeout.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单主表。状态流转：1 待支付 → 2 待接单 → 3 待配送 → 4 配送中 → 5 已完成；6 已取消。
 */
@Data
@TableName("orders")
public class Orders {
    @TableId(type = IdType.AUTO)
    private Long id;
    /** 订单号 */
    private String orderNo;
    private Long userId;
    private Long shopId;
    /** 商品总额 */
    private BigDecimal goodsAmount;
    /** 打包费 */
    private BigDecimal packFee;
    /** 配送费 */
    private BigDecimal deliveryFee;
    /** 实付总额 */
    private BigDecimal totalAmount;
    /** 状态：1待支付 2待接单 3待配送 4配送中 5已完成 6已取消 */
    private Integer status;
    /** 配送员ID：商家接单后订单进入待配送(3)，骑手抢单后写入此字段并置为配送中(4) */
    private Long riderId;
    /** 收货地址快照（下单时复制，避免地址被改后影响历史订单） */
    private String addressSnapshot;
    private String remark;
    private LocalDateTime createTime;
    private LocalDateTime payTime;
    private LocalDateTime finishTime;

    /** 商家接单时间：配送时效计时起点（2→3 时写入） */
    private LocalDateTime acceptTime;
    /** 配送截止时间：默认 = 接单时间 + 60 分钟，骑手延期获批后顺延 */
    private LocalDateTime slaDeadline;
    /** 延期申请状态：0无 / 1待用户审批 / 2已同意 / 3已拒绝 */
    private Integer extendStatus;
    /** 骑手申请延长的分钟数 */
    private Integer extendMinutes;
    /** 骑手申请延期的原因 */
    private String extendReason;

    @TableLogic
    private Integer deleted;
}
