package com.campus.takeout.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.takeout.common.BusinessException;
import com.campus.takeout.common.PageResult;
import com.campus.takeout.entity.Dish;
import com.campus.takeout.entity.Shop;
import com.campus.takeout.mapper.DishMapper;
import com.campus.takeout.mapper.ShopMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 菜品服务：商家管理本店菜品（增删改查、上下架），并做归属校验。
 */
@Service
public class DishService {

    @Autowired
    private DishMapper dishMapper;
    @Autowired
    private ShopMapper shopMapper;

    /** 商家分页查询本店菜品，支持关键词、店内分类、状态筛选 */
    public PageResult<Dish> page(Long shopId, int pageNum, int pageSize, String keyword,
                                 String dishCategory, Integer status) {
        LambdaQueryWrapper<Dish> qw = new LambdaQueryWrapper<>();
        qw.eq(Dish::getShopId, shopId);
        if (keyword != null && !keyword.isEmpty()) {
            qw.like(Dish::getName, keyword);
        }
        if (dishCategory != null && !dishCategory.isEmpty()) {
            qw.eq(Dish::getDishCategory, dishCategory);
        }
        if (status != null) {
            qw.eq(Dish::getStatus, status);
        }
        qw.orderByDesc(Dish::getCreateTime);
        Page<Dish> page = dishMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        return new PageResult<>(page.getTotal(), page.getRecords());
    }

    /** 校验当前商家是否拥有该店铺 */
    private Long checkOwnerShop(Long ownerId) {
        Shop shop = shopMapper.selectOne(new LambdaQueryWrapper<Shop>()
                .eq(Shop::getOwnerId, ownerId).last("limit 1"));
        if (shop == null) {
            throw new BusinessException("您还没有店铺，请先创建店铺");
        }
        return shop.getId();
    }

    public void save(Dish dish, Long ownerId) {
        Long shopId = checkOwnerShop(ownerId);
        dish.setShopId(shopId);
        if (dish.getId() == null) {
            dish.setSales(0);
            dish.setStatus(dish.getStatus() == null ? 1 : dish.getStatus());
            dish.setCreateTime(LocalDateTime.now());
            dishMapper.insert(dish);
        } else {
            Dish exist = dishMapper.selectById(dish.getId());
            if (exist == null || !exist.getShopId().equals(shopId)) {
                throw new BusinessException("无权操作该菜品");
            }
            dish.setShopId(shopId);
            dishMapper.updateById(dish);
        }
    }

    public void delete(Long id, Long ownerId) {
        Long shopId = checkOwnerShop(ownerId);
        Dish exist = dishMapper.selectById(id);
        if (exist == null || !exist.getShopId().equals(shopId)) {
            throw new BusinessException("无权操作该菜品");
        }
        dishMapper.deleteById(id);
    }

    /** 上下架切换 */
    public void updateStatus(Long id, Integer status, Long ownerId) {
        Long shopId = checkOwnerShop(ownerId);
        Dish exist = dishMapper.selectById(id);
        if (exist == null || !exist.getShopId().equals(shopId)) {
            throw new BusinessException("无权操作该菜品");
        }
        exist.setStatus(status);
        dishMapper.updateById(exist);
    }
}
