package com.campus.takeout.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

/**
 * 收货地址：归属某个用户，可设为默认地址。
 */
@Data
@TableName("address")
public class Address {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    /** 收货人 */
    private String name;
    private String phone;
    /** 详细地址 */
    private String detail;
    /** 是否默认：1 是 0 否 */
    private Integer isDefault;

    @TableLogic
    private Integer deleted;
}
