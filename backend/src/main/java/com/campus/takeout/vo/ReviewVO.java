package com.campus.takeout.vo;

import com.campus.takeout.entity.Review;
import lombok.Data;

/**
 * 评价视图：评价信息 + 评价人昵称头像 + 店铺名。
 */
@Data
public class ReviewVO {
    private Review review;
    private String nickname;
    private String avatar;
    private String shopName;
}
