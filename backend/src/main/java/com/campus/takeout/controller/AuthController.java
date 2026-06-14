package com.campus.takeout.controller;

import com.campus.takeout.common.Result;
import com.campus.takeout.common.UserContext;
import com.campus.takeout.dto.LoginDTO;
import com.campus.takeout.dto.PasswordDTO;
import com.campus.takeout.dto.RegisterDTO;
import com.campus.takeout.entity.User;
import com.campus.takeout.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 认证接口：登录、注册为公开接口，其余需登录。
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody @Valid LoginDTO dto) {
        return Result.success("登录成功", authService.login(dto));
    }

    @PostMapping("/register")
    public Result<Map<String, Object>> register(@RequestBody @Valid RegisterDTO dto) {
        return Result.success("注册成功", authService.register(dto));
    }

    @GetMapping("/info")
    public Result<User> info() {
        return Result.success(authService.info(UserContext.getUserId()));
    }

    @PutMapping("/password")
    public Result<Void> updatePassword(@RequestBody @Valid PasswordDTO dto) {
        authService.updatePassword(UserContext.getUserId(), dto);
        return Result.success();
    }
}
