package com.campus.takeout.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class PasswordDTO {
    @NotBlank(message = "请输入原密码")
    private String oldPassword;
    @NotBlank(message = "请输入新密码")
    private String newPassword;
}
