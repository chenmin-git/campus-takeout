package com.campus.takeout.controller;

import com.campus.takeout.common.PageResult;
import com.campus.takeout.common.Result;
import com.campus.takeout.common.UserContext;
import com.campus.takeout.dto.ReviewDTO;
import com.campus.takeout.service.ReviewService;
import com.campus.takeout.vo.ReviewVO;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 评价接口：用户评价、商家回复、按店铺/商家分页查询。
 */
@RestController
@RequestMapping("/api/review")
public class ReviewController {

    @Autowired
    private ReviewService reviewService;

    @PostMapping("/create")
    public Result<Void> create(@RequestBody @Valid ReviewDTO dto) {
        reviewService.create(dto, UserContext.getUserId());
        return Result.success();
    }

    @GetMapping("/shop/{shopId}")
    public Result<PageResult<ReviewVO>> byShop(@PathVariable Long shopId,
                                               @RequestParam(defaultValue = "1") int page,
                                               @RequestParam(defaultValue = "10") int size) {
        return Result.success(reviewService.pageByShop(shopId, page, size));
    }

    @GetMapping("/merchant/page")
    public Result<PageResult<ReviewVO>> byOwner(@RequestParam(defaultValue = "1") int page,
                                                @RequestParam(defaultValue = "10") int size) {
        return Result.success(reviewService.pageByOwner(UserContext.getUserId(), page, size));
    }

    @PutMapping("/reply/{id}")
    public Result<Void> reply(@PathVariable Long id, @RequestBody Map<String, String> body) {
        reviewService.reply(id, body.get("reply"), UserContext.getUserId());
        return Result.success();
    }
}
