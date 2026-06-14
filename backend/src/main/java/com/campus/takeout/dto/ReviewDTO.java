package com.campus.takeout.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ReviewDTO {
    @NotNull(message = "订单不能为空")
    private Long orderId;
    @NotNull(message = "请选择评分")
    private Integer rating;
    private String content;
    /** 多张图片相对路径，逗号分隔 */
    private String images;
}
