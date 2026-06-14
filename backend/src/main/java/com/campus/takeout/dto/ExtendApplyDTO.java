package com.campus.takeout.dto;

import lombok.Data;

/**
 * 骑手申请配送延期入参：延长分钟数 + 原因。
 */
@Data
public class ExtendApplyDTO {
    /** 申请延长的分钟数 */
    private Integer minutes;
    /** 申请延期的原因 */
    private String reason;
}
