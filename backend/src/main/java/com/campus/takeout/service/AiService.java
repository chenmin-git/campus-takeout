package com.campus.takeout.service;

import com.campus.takeout.dto.AiChatDTO;

/**
 * 智能助手服务：对接外部大模型对话接口。
 */
public interface AiService {

    /**
     * 发起一次多轮对话，返回助手回复文本。
     *
     * @param dto 前端传入的对话历史
     * @return 助手回复内容
     */
    String chat(AiChatDTO dto);
}
