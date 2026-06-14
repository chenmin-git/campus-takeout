package com.campus.takeout.vo;

import lombok.Data;

import java.util.Map;

/**
 * 智能助手 Agent 回复：reply 为给用户的自然语言文案；
 * proposal 为本轮生成的「待确认操作提案」（下单/退款/取消/评价），可空。
 *
 * 安全设计：助手不再直接执行写操作，所有写操作都转为提案返回给前端，
 * 由用户在确认卡片上二次确认后，再由前端调用对应业务接口真正执行，杜绝静默下单/扣款。
 */
@Data
public class AgentReplyVO {

    private String reply;

    /** 待用户确认的操作提案；只读查询不产生提案，此处为 null */
    private Proposal proposal;

    public void setProposal(String type, String title, String summary, Map<String, Object> payload) {
        this.proposal = new Proposal(type, title, summary, payload);
    }

    /**
     * 操作提案：前端据此渲染确认卡片。
     * type 决定确认后前端调用哪个接口；payload 为执行所需参数。
     */
    @Data
    public static class Proposal {
        /** 提案类型：place_order / refund_order / cancel_order / review_order */
        private String type;
        /** 卡片标题，如「确认下单并支付」 */
        private String title;
        /** 人类可读摘要：店名、菜品 xN、实付金额 / 订单号 / 评分+内容 */
        private String summary;
        /** 前端执行所需参数（下单为 shopId/addressId/remark/items，其余为 orderId 等） */
        private Map<String, Object> payload;

        public Proposal(String type, String title, String summary, Map<String, Object> payload) {
            this.type = type;
            this.title = title;
            this.summary = summary;
            this.payload = payload;
        }
    }
}
