package com.campus.takeout.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class CreateOrderDTO {
    @NotNull(message = "请选择店铺")
    private Long shopId;
    @NotNull(message = "请选择收货地址")
    private Long addressId;
    private String remark;
    /** 下单菜品列表 */
    private List<OrderItemDTO> items;
}
