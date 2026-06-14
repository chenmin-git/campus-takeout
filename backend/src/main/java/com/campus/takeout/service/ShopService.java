package com.campus.takeout.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.takeout.common.BusinessException;
import com.campus.takeout.common.PageResult;
import com.campus.takeout.entity.Dish;
import com.campus.takeout.entity.Shop;
import com.campus.takeout.entity.ShopCategory;
import com.campus.takeout.mapper.DishMapper;
import com.campus.takeout.mapper.ShopCategoryMapper;
import com.campus.takeout.mapper.ShopMapper;
import com.campus.takeout.vo.ShopDetailVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 店铺服务：用户端浏览营业中店铺，商家端管理自己的店铺，管理员审核店铺。
 */
@Service
public class ShopService {

    @Autowired
    private ShopMapper shopMapper;
    @Autowired
    private DishMapper dishMapper;
    @Autowired
    private ShopCategoryMapper categoryMapper;

    /**
     * 分页查询店铺。
     * @param onlyOpen true 时只返回营业中（用户端用），false 返回全部（管理员用）
     */
    public PageResult<Shop> page(int pageNum, int pageSize, String keyword, Long categoryId,
                                 Integer status, boolean onlyOpen) {
        LambdaQueryWrapper<Shop> qw = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isEmpty()) {
            qw.like(Shop::getName, keyword);
        }
        if (categoryId != null) {
            qw.eq(Shop::getCategoryId, categoryId);
        }
        if (onlyOpen) {
            qw.eq(Shop::getStatus, 1);
        } else if (status != null) {
            qw.eq(Shop::getStatus, status);
        }
        qw.orderByDesc(Shop::getSales);
        Page<Shop> page = shopMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        return new PageResult<>(page.getTotal(), page.getRecords());
    }

    /** 店铺详情：返回店铺信息和在售菜品 */
    public ShopDetailVO detail(Long shopId) {
        Shop shop = shopMapper.selectById(shopId);
        if (shop == null) {
            throw new BusinessException("店铺不存在");
        }
        List<Dish> dishes = dishMapper.selectList(new LambdaQueryWrapper<Dish>()
                .eq(Dish::getShopId, shopId)
                .eq(Dish::getStatus, 1)
                .orderByDesc(Dish::getSales));
        ShopDetailVO vo = new ShopDetailVO();
        vo.setShop(shop);
        vo.setDishes(dishes);
        if (shop.getCategoryId() != null) {
            ShopCategory c = categoryMapper.selectById(shop.getCategoryId());
            vo.setCategoryName(c != null ? c.getName() : null);
        }
        return vo;
    }

    /** 获取某商家用户名下的店铺 */
    public Shop getByOwner(Long ownerId) {
        return shopMapper.selectOne(new LambdaQueryWrapper<Shop>()
                .eq(Shop::getOwnerId, ownerId).last("limit 1"));
    }

    /** 商家保存/更新自己的店铺，新建时状态为待审核 */
    public void saveOrUpdate(Shop shop, Long ownerId) {
        shop.setOwnerId(ownerId);
        if (shop.getId() == null) {
            shop.setStatus(0);
            shop.setRating(new java.math.BigDecimal("5.0"));
            shop.setSales(0);
            shop.setCreateTime(LocalDateTime.now());
            shopMapper.insert(shop);
        } else {
            Shop exist = shopMapper.selectById(shop.getId());
            if (exist == null || !exist.getOwnerId().equals(ownerId)) {
                throw new BusinessException("无权操作该店铺");
            }
            // 不允许商家直接改审核状态
            shop.setStatus(exist.getStatus());
            shop.setOwnerId(ownerId);
            shopMapper.updateById(shop);
        }
    }

    /** 管理员审核：status=1 通过营业，3 驳回 */
    public void audit(Long shopId, Integer status) {
        Shop shop = shopMapper.selectById(shopId);
        if (shop == null) {
            throw new BusinessException("店铺不存在");
        }
        shop.setStatus(status);
        shopMapper.updateById(shop);
    }

    public void delete(Long shopId) {
        shopMapper.deleteById(shopId);
    }
}
