package com.campus.takeout.controller;

import com.campus.takeout.common.PageResult;
import com.campus.takeout.common.Result;
import com.campus.takeout.common.UserContext;
import com.campus.takeout.dto.CreateOrderDTO;
import com.campus.takeout.dto.ExtendApplyDTO;
import com.campus.takeout.service.OrderService;
import com.campus.takeout.vo.OrderVO;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 订单接口：用户下单/支付/取消/确认收货，商家推进状态，三角色分页查询。
 */
@RestController
@RequestMapping("/api/order")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @PostMapping("/create")
    public Result<Long> create(@RequestBody @Valid CreateOrderDTO dto) {
        return Result.success("下单成功", orderService.create(dto, UserContext.getUserId()));
    }

    @PutMapping("/pay/{id}")
    public Result<Void> pay(@PathVariable Long id) {
        orderService.pay(id, UserContext.getUserId());
        return Result.success();
    }

    @PutMapping("/cancel/{id}")
    public Result<Void> cancel(@PathVariable Long id) {
        orderService.cancel(id, UserContext.getUserId());
        return Result.success();
    }

    @PutMapping("/confirm/{id}")
    public Result<Void> confirm(@PathVariable Long id) {
        orderService.confirm(id, UserContext.getUserId());
        return Result.success();
    }

    /** 用户退款：已支付未完成订单（2/3/4）→ 已取消(6) */
    @PutMapping("/refund/{id}")
    public Result<Void> refund(@PathVariable Long id) {
        orderService.refund(id, UserContext.getUserId());
        return Result.success();
    }

    /** 商家接单：仅 2→3（接单后转入待配送，等待骑手抢单） */
    @PutMapping("/advance/{id}/{status}")
    public Result<Void> advance(@PathVariable Long id, @PathVariable Integer status) {
        orderService.merchantAdvance(id, UserContext.getUserId(), status);
        return Result.success();
    }

    /** 骑手抢单：待配送(3) → 配送中(4) */
    @PutMapping("/rider/grab/{id}")
    public Result<Void> riderGrab(@PathVariable Long id) {
        orderService.riderGrab(id, UserContext.getUserId());
        return Result.success();
    }

    /** 骑手送达：配送中(4) → 已完成(5) */
    @PutMapping("/rider/deliver/{id}")
    public Result<Void> riderDeliver(@PathVariable Long id) {
        orderService.riderDeliver(id, UserContext.getUserId());
        return Result.success();
    }

    /** 骑手申请配送延期：配送中(4) 订单填写延长分钟数与原因，待用户审批 */
    @PutMapping("/rider/extend/{id}")
    public Result<Void> riderRequestExtend(@PathVariable Long id, @RequestBody ExtendApplyDTO dto) {
        orderService.riderRequestExtend(id, UserContext.getUserId(), dto.getMinutes(), dto.getReason());
        return Result.success();
    }

    /** 用户审批延期申请：approve=1 同意（时效顺延）/ 0 拒绝 */
    @PutMapping("/extend/{id}/{approve}")
    public Result<Void> decideExtend(@PathVariable Long id, @PathVariable Integer approve) {
        orderService.userDecideExtend(id, UserContext.getUserId(), approve != null && approve == 1);
        return Result.success();
    }

    /** 骑手抢单大厅：待配送且未分配骑手的订单 */
    @GetMapping("/rider/available")
    public Result<PageResult<OrderVO>> riderAvailable(@RequestParam(defaultValue = "1") int page,
                                                      @RequestParam(defaultValue = "10") int size) {
        return Result.success(orderService.riderAvailablePage(page, size));
    }

    /** 骑手我的配送订单 */
    @GetMapping("/rider/page")
    public Result<PageResult<OrderVO>> riderPage(@RequestParam(defaultValue = "1") int page,
                                                 @RequestParam(defaultValue = "10") int size,
                                                 @RequestParam(required = false) Integer status) {
        return Result.success(orderService.riderMyPage(UserContext.getUserId(), page, size, status));
    }

    @GetMapping("/user/page")
    public Result<PageResult<OrderVO>> userPage(@RequestParam(defaultValue = "1") int page,
                                                @RequestParam(defaultValue = "10") int size,
                                                @RequestParam(required = false) Integer status) {
        return Result.success(orderService.userPage(UserContext.getUserId(), page, size, status));
    }

    @GetMapping("/merchant/page")
    public Result<PageResult<OrderVO>> merchantPage(@RequestParam(defaultValue = "1") int page,
                                                    @RequestParam(defaultValue = "10") int size,
                                                    @RequestParam(required = false) Integer status) {
        return Result.success(orderService.merchantPage(UserContext.getUserId(), page, size, status));
    }

    @GetMapping("/admin/page")
    public Result<PageResult<OrderVO>> adminPage(@RequestParam(defaultValue = "1") int page,
                                                 @RequestParam(defaultValue = "10") int size,
                                                 @RequestParam(required = false) Integer status,
                                                 @RequestParam(required = false) String keyword) {
        return Result.success(orderService.adminPage(page, size, status, keyword));
    }

    @GetMapping("/detail/{id}")
    public Result<OrderVO> detail(@PathVariable Long id) {
        return Result.success(orderService.detail(id));
    }
}
