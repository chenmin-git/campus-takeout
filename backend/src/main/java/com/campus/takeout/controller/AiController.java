package com.campus.takeout.controller;

import com.campus.takeout.common.Result;
import com.campus.takeout.common.UserContext;
import com.campus.takeout.dto.AiChatDTO;
import com.campus.takeout.service.AgentService;
import com.campus.takeout.service.AiService;
import com.campus.takeout.vo.AgentReplyVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 智能助手接口：仅登录用户可用（受全局登录拦截器保护），后端代理调用大模型。
 */
@RestController
@RequestMapping("/api/ai")
public class AiController {

    @Autowired
    private AiService aiService;
    @Autowired
    private AgentService agentService;

    /** 智能点餐助手对话 */
    @PostMapping("/chat")
    public Result<String> chat(@RequestBody AiChatDTO dto) {
        try {
            return Result.success(aiService.chat(dto));
        } catch (Exception e) {
            // 外部接口不稳定时给出友好提示，不把底层错误细节直接抛给前端
            return Result.error("智能助手暂时不可用，请稍后再试");
        }
    }

    /**
     * Agent 对话：可执行下单/查询/评价/退款/取消等操作。
     * 所有写操作以当前登录用户身份进行（UserContext），不接受前端传入的用户标识。
     */
    @PostMapping("/agent")
    public Result<AgentReplyVO> agent(@RequestBody AiChatDTO dto) {
        try {
            return Result.success(agentService.run(dto, UserContext.getUserId()));
        } catch (Exception e) {
            return Result.error("智能助手暂时不可用，请稍后再试");
        }
    }
}
