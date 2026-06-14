package com.campus.takeout.dto;

import lombok.Data;

@Data
public class OrderItemDTO {
    private Long dishId;
    private Integer quantity;
}
