package com.campus.takeout.common;

/**
 * 业务异常，用于在 Service 层抛出可读的中文错误信息，由全局异常处理统一捕获。
 */
public class BusinessException extends RuntimeException {
    public BusinessException(String message) {
        super(message);
    }
}
