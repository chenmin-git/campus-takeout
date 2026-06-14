package com.campus.takeout.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RegisterDTO {
    @NotBlank(message = "请输入用户名")
    private String username;
    @NotBlank(message = "请输入密码")
    private String password;
    private String nickname;
    private String phone;
    /** 注册角色：USER 或 MERCHANT，默认 USER */
    private String role;
}
