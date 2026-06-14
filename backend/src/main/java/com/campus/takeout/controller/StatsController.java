package com.campus.takeout.controller;

import com.campus.takeout.common.Result;
import com.campus.takeout.common.UserContext;
import com.campus.takeout.service.StatsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 工作台统计接口：根据当前登录角色返回对应统计数据。
 */
@RestController
@RequestMapping("/api/stats")
public class StatsController {

    @Autowired
    private StatsService statsService;

    @GetMapping("/admin")
    public Result<Map<String, Object>> admin() {
        return Result.success(statsService.adminStats());
    }

    @GetMapping("/merchant")
    public Result<Map<String, Object>> merchant() {
        return Result.success(statsService.merchantStats(UserContext.getUserId()));
    }

    @GetMapping("/user")
    public Result<Map<String, Object>> user() {
        return Result.success(statsService.userStats(UserContext.getUserId()));
    }

    @GetMapping("/rider")
    public Result<Map<String, Object>> rider() {
        return Result.success(statsService.riderStats(UserContext.getUserId()));
    }
}
