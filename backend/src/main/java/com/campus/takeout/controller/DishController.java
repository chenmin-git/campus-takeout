package com.campus.takeout.controller;

import com.campus.takeout.common.PageResult;
import com.campus.takeout.common.Result;
import com.campus.takeout.common.UserContext;
import com.campus.takeout.entity.Dish;
import com.campus.takeout.service.DishService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 菜品接口：商家维护本店菜品。
 */
@RestController
@RequestMapping("/api/dish")
public class DishController {

    @Autowired
    private DishService dishService;

    /** 商家分页查询本店菜品 */
    @GetMapping("/page")
    public Result<PageResult<Dish>> page(@RequestParam Long shopId,
                                         @RequestParam(defaultValue = "1") int page,
                                         @RequestParam(defaultValue = "10") int size,
                                         @RequestParam(required = false) String keyword,
                                         @RequestParam(required = false) String dishCategory,
                                         @RequestParam(required = false) Integer status) {
        return Result.success(dishService.page(shopId, page, size, keyword, dishCategory, status));
    }

    @PostMapping("/save")
    public Result<Void> save(@RequestBody Dish dish) {
        dishService.save(dish, UserContext.getUserId());
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        dishService.delete(id, UserContext.getUserId());
        return Result.success();
    }

    @PutMapping("/status/{id}/{status}")
    public Result<Void> updateStatus(@PathVariable Long id, @PathVariable Integer status) {
        dishService.updateStatus(id, status, UserContext.getUserId());
        return Result.success();
    }
}
