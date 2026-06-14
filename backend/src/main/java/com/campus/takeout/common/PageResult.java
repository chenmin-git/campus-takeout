package com.campus.takeout.common;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;

/**
 * 分页结果对象，统一返回总条数与当前页数据。
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PageResult<T> implements Serializable {
    /** 总记录数 */
    private Long total;
    /** 当前页数据 */
    private List<T> records;
}
