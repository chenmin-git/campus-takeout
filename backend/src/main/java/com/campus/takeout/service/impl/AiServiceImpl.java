package com.campus.takeout.service.impl;

import cn.hutool.http.HttpRequest;
import cn.hutool.http.HttpResponse;
import cn.hutool.json.JSONArray;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.campus.takeout.dto.AiChatDTO;
import com.campus.takeout.service.AiService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * 智能助手实现：把前端对话历史拼上系统提示词后，调用 OpenAI 兼容的大模型接口。
 * 密钥只读自后端配置，绝不下发前端；对外统一称“智能助手”，不暴露底层服务商。
 */
@Service
public class AiServiceImpl implements AiService {

    @Value("${ai.api-url}")
    private String apiUrl;

    @Value("${ai.api-password}")
    private String apiPassword;

    @Value("${ai.model}")
    private String model;

    @Value("${ai.max-tokens:1024}")
    private Integer maxTokens;

    /** 系统提示词：限定助手身份为校园外卖点餐助手，避免跑题，回复尽量简洁 */
    private static final String SYSTEM_PROMPT =
            "你是校园外卖系统的智能点餐助手。你的职责是为校园用户推荐美食、解答点餐、配送、订单相关问题，"
                    + "并根据用户的口味、预算和场景给出贴心建议。请使用简体中文，回答简洁友好，控制在 150 字以内，"
                    + "不要回答与餐饮、点餐无关的问题。";

    @Override
    public String chat(AiChatDTO dto) {
        // 组装消息：系统提示词在前，再附用户多轮历史；只保留最近 10 条以控制 token 消耗
        JSONArray messages = new JSONArray();
        JSONObject system = new JSONObject();
        system.set("role", "system");
        system.set("content", SYSTEM_PROMPT);
        messages.add(system);

        if (!CollectionUtils.isEmpty(dto.getMessages())) {
            List<AiChatDTO.Message> history = dto.getMessages();
            int from = Math.max(0, history.size() - 10);
            for (int i = from; i < history.size(); i++) {
                AiChatDTO.Message m = history.get(i);
                if (m == null || m.getContent() == null || m.getContent().isBlank()) {
                    continue;
                }
                JSONObject msg = new JSONObject();
                // 仅允许 user / assistant 两种角色，防止前端伪造 system
                msg.set("role", "assistant".equals(m.getRole()) ? "assistant" : "user");
                msg.set("content", m.getContent());
                messages.add(msg);
            }
        }

        String effectiveApiUrl = StringUtils.hasText(apiUrl) ? apiUrl : dto.getApiUrl();
        String effectivePassword = StringUtils.hasText(apiPassword) ? apiPassword : dto.getApiPassword();
        String effectiveModel = StringUtils.hasText(model) ? model : dto.getModel();
        if (!StringUtils.hasText(effectiveApiUrl) || !StringUtils.hasText(effectivePassword) || !StringUtils.hasText(effectiveModel)) {
            throw new RuntimeException("请先配置 AI 接口地址、口令和模型");
        }

        JSONObject body = new JSONObject();
        body.set("model", effectiveModel);
        body.set("messages", messages);
        body.set("temperature", 0.7);
        body.set("max_tokens", maxTokens);
        body.set("stream", false);

        try (HttpResponse resp = HttpRequest.post(effectiveApiUrl)
                .header("Authorization", "Bearer " + effectivePassword)
                .header("Content-Type", "application/json")
                .body(body.toString())
                .timeout(30000)
                .execute()) {

            String respBody = resp.body();
            if (!resp.isOk()) {
                throw new RuntimeException("AI 接口返回异常状态：" + resp.getStatus() + "，" + respBody);
            }
            JSONObject json = JSONUtil.parseObj(respBody);
            // 兼容错误返回：部分错误也会以 200 + 错误码形式返回
            if (json.containsKey("code") && json.getInt("code", 0) != 0) {
                throw new RuntimeException("AI 接口业务异常：" + json.getStr("message"));
            }
            JSONArray choices = json.getJSONArray("choices");
            if (choices == null || choices.isEmpty()) {
                throw new RuntimeException("AI 接口未返回有效回复");
            }
            return choices.getJSONObject(0).getJSONObject("message").getStr("content");
        }
    }
}
