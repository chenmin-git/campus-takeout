package com.campus.takeout.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.takeout.entity.Orders;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrdersMapper extends BaseMapper<Orders> {
}
