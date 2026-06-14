package com.campus.takeout.controller;

import com.campus.takeout.common.PageResult;
import com.campus.takeout.common.Result;
import com.campus.takeout.common.UserContext;
import com.campus.takeout.entity.Shop;
import com.campus.takeout.service.ShopService;
import com.campus.takeout.vo.ShopDetailVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 店铺接口：用户端浏览、商家端维护、管理员审核。
 */
@RestController
@RequestMapping("/api/shop")
public class ShopController {

    @Autowired
    private ShopService shopService;

    /** 用户端：分页查询营业中的店铺 */
    @GetMapping("/list")
    public Result<PageResult<Shop>> list(@RequestParam(defaultValue = "1") int page,
                                         @RequestParam(defaultValue = "10") int size,
                                         @RequestParam(required = false) String keyword,
                                         @RequestParam(required = false) Long categoryId) {
        return Result.success(shopService.page(page, size, keyword, categoryId, null, true));
    }

    /** 管理员：分页查询全部店铺，可按状态筛选 */
    @GetMapping("/admin/list")
    public Result<PageResult<Shop>> adminList(@RequestParam(defaultValue = "1") int page,
                                              @RequestParam(defaultValue = "10") int size,
                                              @RequestParam(required = false) String keyword,
                                              @RequestParam(required = false) Long categoryId,
                                              @RequestParam(required = false) Integer status) {
        return Result.success(shopService.page(page, size, keyword, categoryId, status, false));
    }

    @GetMapping("/detail/{id}")
    public Result<ShopDetailVO> detail(@PathVariable Long id) {
        return Result.success(shopService.detail(id));
    }

    /** 商家：获取自己的店铺 */
    @GetMapping("/mine")
    public Result<Shop> mine() {
        return Result.success(shopService.getByOwner(UserContext.getUserId()));
    }

    /** 商家：保存/更新自己的店铺 */
    @PostMapping("/save")
    public Result<Void> save(@RequestBody Shop shop) {
        shopService.saveOrUpdate(shop, UserContext.getUserId());
        return Result.success();
    }

    /** 管理员：审核店铺 */
    @PutMapping("/audit/{id}/{status}")
    public Result<Void> audit(@PathVariable Long id, @PathVariable Integer status) {
        shopService.audit(id, status);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        shopService.delete(id);
        return Result.success();
    }
}
