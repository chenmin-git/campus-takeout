package com.campus.takeout.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.takeout.common.PageResult;
import com.campus.takeout.common.Result;
import com.campus.takeout.entity.Notice;
import com.campus.takeout.mapper.NoticeMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 公告接口：用户端读取最新公告，管理员维护公告。
 */
@RestController
@RequestMapping("/api/notice")
public class NoticeController {

    @Autowired
    private NoticeMapper noticeMapper;

    /** 用户端首页最新公告 */
    @GetMapping("/latest")
    public Result<List<Notice>> latest() {
        return Result.success(noticeMapper.selectList(new LambdaQueryWrapper<Notice>()
                .orderByDesc(Notice::getCreateTime).last("limit 5")));
    }

    /** 管理员分页 */
    @GetMapping("/page")
    public Result<PageResult<Notice>> page(@RequestParam(defaultValue = "1") int page,
                                           @RequestParam(defaultValue = "10") int size,
                                           @RequestParam(required = false) String keyword) {
        LambdaQueryWrapper<Notice> qw = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isEmpty()) {
            qw.like(Notice::getTitle, keyword);
        }
        qw.orderByDesc(Notice::getCreateTime);
        Page<Notice> p = noticeMapper.selectPage(new Page<>(page, size), qw);
        return Result.success(new PageResult<>(p.getTotal(), p.getRecords()));
    }

    @PostMapping("/save")
    public Result<Void> save(@RequestBody Notice notice) {
        if (notice.getId() == null) {
            notice.setCreateTime(LocalDateTime.now());
            noticeMapper.insert(notice);
        } else {
            noticeMapper.updateById(notice);
        }
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        noticeMapper.deleteById(id);
        return Result.success();
    }
}
