package com.campus.takeout.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.takeout.entity.OrderItem;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrderItemMapper extends BaseMapper<OrderItem> {
}
