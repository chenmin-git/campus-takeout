package com.campus.takeout.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.takeout.common.BusinessException;
import com.campus.takeout.common.PageResult;
import com.campus.takeout.dto.ReviewDTO;
import com.campus.takeout.entity.Orders;
import com.campus.takeout.entity.Review;
import com.campus.takeout.entity.Shop;
import com.campus.takeout.entity.User;
import com.campus.takeout.mapper.OrdersMapper;
import com.campus.takeout.mapper.ReviewMapper;
import com.campus.takeout.mapper.ShopMapper;
import com.campus.takeout.mapper.UserMapper;
import com.campus.takeout.vo.ReviewVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 评价服务：用户对已完成订单评价，提交后刷新店铺平均评分；商家可回复。
 */
@Service
public class ReviewService {

    @Autowired
    private ReviewMapper reviewMapper;
    @Autowired
    private OrdersMapper ordersMapper;
    @Autowired
    private ShopMapper shopMapper;
    @Autowired
    private UserMapper userMapper;

    public void create(ReviewDTO dto, Long userId) {
        Orders order = ordersMapper.selectById(dto.getOrderId());
        if (order == null || !order.getUserId().equals(userId)) {
            throw new BusinessException("订单不存在");
        }
        if (order.getStatus() != 5) {
            throw new BusinessException("订单完成后才能评价");
        }
        Long cnt = reviewMapper.selectCount(new LambdaQueryWrapper<Review>()
                .eq(Review::getOrderId, order.getId()));
        if (cnt != null && cnt > 0) {
            throw new BusinessException("该订单已评价");
        }
        Review review = new Review();
        review.setOrderId(order.getId());
        review.setUserId(userId);
        review.setShopId(order.getShopId());
        review.setRating(dto.getRating());
        review.setContent(dto.getContent());
        review.setImages(dto.getImages());
        review.setCreateTime(LocalDateTime.now());
        reviewMapper.insert(review);
        refreshShopRating(order.getShopId());
    }

    /** 重新计算店铺平均评分 */
    private void refreshShopRating(Long shopId) {
        List<Review> all = reviewMapper.selectList(new LambdaQueryWrapper<Review>()
                .eq(Review::getShopId, shopId));
        if (all.isEmpty()) {
            return;
        }
        int sum = all.stream().mapToInt(Review::getRating).sum();
        BigDecimal avg = BigDecimal.valueOf(sum)
                .divide(BigDecimal.valueOf(all.size()), 1, RoundingMode.HALF_UP);
        Shop shop = shopMapper.selectById(shopId);
        if (shop != null) {
            shop.setRating(avg);
            shopMapper.updateById(shop);
        }
    }

    /** 商家回复评价 */
    public void reply(Long reviewId, String reply, Long ownerId) {
        Review review = reviewMapper.selectById(reviewId);
        if (review == null) {
            throw new BusinessException("评价不存在");
        }
        Shop shop = shopMapper.selectById(review.getShopId());
        if (shop == null || !shop.getOwnerId().equals(ownerId)) {
            throw new BusinessException("无权回复该评价");
        }
        review.setReply(reply);
        reviewMapper.updateById(review);
    }

    /** 按店铺分页查询评价（用户端店铺详情、商家端评价管理共用） */
    public PageResult<ReviewVO> pageByShop(Long shopId, int pageNum, int pageSize) {
        Page<Review> page = reviewMapper.selectPage(new Page<>(pageNum, pageSize),
                new LambdaQueryWrapper<Review>()
                        .eq(Review::getShopId, shopId)
                        .orderByDesc(Review::getCreateTime));
        return toVoPage(page);
    }

    /** 商家查询本店评价 */
    public PageResult<ReviewVO> pageByOwner(Long ownerId, int pageNum, int pageSize) {
        Shop shop = shopMapper.selectOne(new LambdaQueryWrapper<Shop>()
                .eq(Shop::getOwnerId, ownerId).last("limit 1"));
        if (shop == null) {
            return new PageResult<>(0L, new ArrayList<>());
        }
        return pageByShop(shop.getId(), pageNum, pageSize);
    }

    private PageResult<ReviewVO> toVoPage(Page<Review> page) {
        List<ReviewVO> list = new ArrayList<>();
        for (Review r : page.getRecords()) {
            ReviewVO vo = new ReviewVO();
            vo.setReview(r);
            User u = userMapper.selectById(r.getUserId());
            if (u != null) {
                vo.setNickname(u.getNickname());
                vo.setAvatar(u.getAvatar());
            }
            list.add(vo);
        }
        return new PageResult<>(page.getTotal(), list);
    }
}
