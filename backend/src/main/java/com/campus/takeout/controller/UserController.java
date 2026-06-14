package com.campus.takeout.controller;

import cn.hutool.crypto.SecureUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.takeout.common.PageResult;
import com.campus.takeout.common.Result;
import com.campus.takeout.entity.User;
import com.campus.takeout.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 用户管理接口（管理员使用）：分页查询、禁用/启用、重置密码、删除。
 */
@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private UserMapper userMapper;

    @GetMapping("/page")
    public Result<PageResult<User>> page(@RequestParam(defaultValue = "1") int page,
                                         @RequestParam(defaultValue = "10") int size,
                                         @RequestParam(required = false) String keyword,
                                         @RequestParam(required = false) String role,
                                         @RequestParam(required = false) Integer status) {
        LambdaQueryWrapper<User> qw = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isEmpty()) {
            qw.and(w -> w.like(User::getUsername, keyword).or().like(User::getNickname, keyword));
        }
        if (role != null && !role.isEmpty()) {
            qw.eq(User::getRole, role);
        }
        if (status != null) {
            qw.eq(User::getStatus, status);
        }
        qw.orderByDesc(User::getCreateTime);
        Page<User> p = userMapper.selectPage(new Page<>(page, size), qw);
        p.getRecords().forEach(u -> u.setPassword(null));
        return Result.success(new PageResult<>(p.getTotal(), p.getRecords()));
    }

    /** 启用/禁用 */
    @PutMapping("/status/{id}/{status}")
    public Result<Void> status(@PathVariable Long id, @PathVariable Integer status) {
        User u = userMapper.selectById(id);
        if (u != null) {
            u.setStatus(status);
            userMapper.updateById(u);
        }
        return Result.success();
    }

    /** 重置密码为 123456 */
    @PutMapping("/reset/{id}")
    public Result<Void> reset(@PathVariable Long id) {
        User u = userMapper.selectById(id);
        if (u != null) {
            u.setPassword(SecureUtil.md5("123456"));
            userMapper.updateById(u);
        }
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        userMapper.deleteById(id);
        return Result.success();
    }
}
