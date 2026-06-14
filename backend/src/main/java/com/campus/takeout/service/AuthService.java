package com.campus.takeout.service;

import cn.hutool.crypto.SecureUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.takeout.common.BusinessException;
import com.campus.takeout.common.JwtUtil;
import com.campus.takeout.dto.LoginDTO;
import com.campus.takeout.dto.PasswordDTO;
import com.campus.takeout.dto.RegisterDTO;
import com.campus.takeout.entity.User;
import com.campus.takeout.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 认证服务：登录、注册、修改密码。密码统一使用 md5 存储与校验。
 */
@Service
public class AuthService {

    @Autowired
    private UserMapper userMapper;
    @Autowired
    private JwtUtil jwtUtil;

    /** 登录：校验账号密码与状态，成功返回 token 和用户信息 */
    public Map<String, Object> login(LoginDTO dto) {
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, dto.getUsername()));
        if (user == null) {
            throw new BusinessException("用户名不存在");
        }
        // 前端传明文，这里 md5 后比对
        if (!SecureUtil.md5(dto.getPassword()).equals(user.getPassword())) {
            throw new BusinessException("密码错误");
        }
        if (user.getStatus() == null || user.getStatus() == 0) {
            throw new BusinessException("账号已被禁用，请联系管理员");
        }
        return buildLoginResult(user);
    }

    /** 注册：用户名不可重复，仅允许注册普通用户或商家 */
    public Map<String, Object> register(RegisterDTO dto) {
        Long exists = userMapper.selectCount(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, dto.getUsername()));
        if (exists != null && exists > 0) {
            throw new BusinessException("用户名已存在");
        }
        String role = "MERCHANT".equals(dto.getRole()) ? "MERCHANT" : "USER";
        User user = new User();
        user.setUsername(dto.getUsername());
        user.setPassword(SecureUtil.md5(dto.getPassword()));
        user.setNickname(dto.getNickname() == null || dto.getNickname().isEmpty() ? dto.getUsername() : dto.getNickname());
        user.setPhone(dto.getPhone());
        user.setRole(role);
        user.setStatus(1);
        user.setCreateTime(LocalDateTime.now());
        userMapper.insert(user);
        return buildLoginResult(user);
    }

    /** 修改密码：校验原密码 */
    public void updatePassword(Long userId, PasswordDTO dto) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        if (!SecureUtil.md5(dto.getOldPassword()).equals(user.getPassword())) {
            throw new BusinessException("原密码错误");
        }
        user.setPassword(SecureUtil.md5(dto.getNewPassword()));
        userMapper.updateById(user);
    }

    public User info(Long userId) {
        User user = userMapper.selectById(userId);
        if (user != null) {
            user.setPassword(null);
        }
        return user;
    }

    private Map<String, Object> buildLoginResult(User user) {
        String token = jwtUtil.createToken(user.getId(), user.getUsername(), user.getRole());
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        user.setPassword(null);
        result.put("user", user);
        return result;
    }
}
