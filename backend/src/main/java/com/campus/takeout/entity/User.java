package com.campus.takeout.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户表（三角色统一）：USER 普通用户、MERCHANT 商家、ADMIN 管理员。
 */
@Data
@TableName("user")
public class User {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String username;
    private String password;
    private String nickname;
    private String avatar;
    private String phone;
    /** 角色：USER / MERCHANT / ADMIN */
    private String role;
    /** 状态：1 正常 0 禁用 */
    private Integer status;
    private LocalDateTime createTime;

    @TableLogic
    private Integer deleted;
}
