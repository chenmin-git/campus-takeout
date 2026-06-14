package com.campus.takeout.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.campus.takeout.common.BusinessException;
import com.campus.takeout.common.Result;
import com.campus.takeout.common.UserContext;
import com.campus.takeout.entity.Address;
import com.campus.takeout.mapper.AddressMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 收货地址接口：当前用户的地址增删改查，支持设为默认。
 */
@RestController
@RequestMapping("/api/address")
public class AddressController {

    @Autowired
    private AddressMapper addressMapper;

    @GetMapping("/list")
    public Result<List<Address>> list() {
        Long userId = UserContext.getUserId();
        return Result.success(addressMapper.selectList(new LambdaQueryWrapper<Address>()
                .eq(Address::getUserId, userId)
                .orderByDesc(Address::getIsDefault)));
    }

    @PostMapping("/save")
    public Result<Void> save(@RequestBody Address address) {
        Long userId = UserContext.getUserId();
        address.setUserId(userId);
        // 设为默认时，先清除其它默认
        if (address.getIsDefault() != null && address.getIsDefault() == 1) {
            addressMapper.update(null, new LambdaUpdateWrapper<Address>()
                    .eq(Address::getUserId, userId).set(Address::getIsDefault, 0));
        }
        if (address.getId() == null) {
            addressMapper.insert(address);
        } else {
            Address exist = addressMapper.selectById(address.getId());
            if (exist == null || !exist.getUserId().equals(userId)) {
                throw new BusinessException("无权操作该地址");
            }
            addressMapper.updateById(address);
        }
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        Address exist = addressMapper.selectById(id);
        if (exist == null || !exist.getUserId().equals(UserContext.getUserId())) {
            throw new BusinessException("无权操作该地址");
        }
        addressMapper.deleteById(id);
        return Result.success();
    }
}
