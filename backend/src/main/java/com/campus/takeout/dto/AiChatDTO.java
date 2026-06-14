package com.campus.takeout.dto;

import lombok.Data;

import java.util.List;

/**
 * 智能助手对话请求体：携带前端的多轮对话历史（不含系统提示词，系统提示词由后端注入）。
 */
@Data
public class AiChatDTO {

    /** 多轮消息列表，role 取 user / assistant，content 为文本内容 */
    private List<Message> messages;

    @Data
    public static class Message {
        private String role;
        private String content;
    }
}
