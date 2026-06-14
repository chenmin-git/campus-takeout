package com.campus.takeout.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.takeout.common.Result;
import com.campus.takeout.entity.ShopCategory;
import com.campus.takeout.mapper.ShopCategoryMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 店铺分类接口：列表所有人可见，增删改由管理员使用。
 */
@RestController
@RequestMapping("/api/category")
public class CategoryController {

    @Autowired
    private ShopCategoryMapper categoryMapper;

    @GetMapping("/list")
    public Result<List<ShopCategory>> list() {
        return Result.success(categoryMapper.selectList(
                new LambdaQueryWrapper<ShopCategory>().orderByAsc(ShopCategory::getSort)));
    }

    @PostMapping("/save")
    public Result<Void> save(@RequestBody ShopCategory category) {
        if (category.getId() == null) {
            categoryMapper.insert(category);
        } else {
            categoryMapper.updateById(category);
        }
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        categoryMapper.deleteById(id);
        return Result.success();
    }
}
