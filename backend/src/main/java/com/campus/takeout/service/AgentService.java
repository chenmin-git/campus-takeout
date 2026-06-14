package com.campus.takeout.service;

import cn.hutool.http.HttpRequest;
import cn.hutool.http.HttpResponse;
import cn.hutool.json.JSONArray;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.takeout.common.BusinessException;
import com.campus.takeout.common.PageResult;
import com.campus.takeout.dto.AiChatDTO;
import com.campus.takeout.dto.OrderItemDTO;
import com.campus.takeout.entity.Address;
import com.campus.takeout.entity.Dish;
import com.campus.takeout.entity.Orders;
import com.campus.takeout.entity.Shop;
import com.campus.takeout.mapper.AddressMapper;
import com.campus.takeout.mapper.DishMapper;
import com.campus.takeout.mapper.OrdersMapper;
import com.campus.takeout.mapper.ShopMapper;
import com.campus.takeout.vo.AgentReplyVO;
import com.campus.takeout.vo.OrderVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 聊天 Agent 服务：让智能助手不仅能问答，还能「通过对话执行操作」——查店铺/菜品、下单购买、查询订单、评价、退款、取消。
 *
 * 设计要点：
 * 1. 采用模型无关的「ReAct + JSON 工具协议」，不依赖特定厂商的 function-calling，任意 OpenAI 兼容模型均可驱动，演示稳定。
 * 2. 多轮循环：模型输出工具调用 → 后端执行 → 把结果回灌给模型 → 直到模型给出自然语言最终答复（最多 MAX_TURNS 轮）。
 * 3. 安全边界：所有写操作一律使用服务端登录态 userId，绝不信任模型传入的用户身份；越权或非法状态由各业务 Service 抛出并转为错误回灌，模型据此向用户解释。
 */
@Service
public class AgentService {

    @Value("${ai.api-url}")
    private String apiUrl;
    @Value("${ai.api-password}")
    private String apiPassword;
    @Value("${ai.model}")
    private String model;
    @Value("${ai.max-tokens:1024}")
    private Integer maxTokens;

    @Autowired
    private OrderService orderService;
    @Autowired
    private ShopMapper shopMapper;
    @Autowired
    private DishMapper dishMapper;
    @Autowired
    private AddressMapper addressMapper;
    @Autowired
    private OrdersMapper ordersMapper;

    /** 单次会话最多与模型往返的轮数，避免工具调用死循环空耗 token */
    private static final int MAX_TURNS = 6;

    /** 从模型回复中提取工具调用代码块 ```tool {json} ``` */
    private static final Pattern TOOL_BLOCK = Pattern.compile("```tool\\s*(\\{[\\s\\S]*?})\\s*```");

    /** 系统提示词：定义助手身份、可用工具与调用协议（给出示例，提升小模型遵循度） */
    private static final String SYSTEM_PROMPT =
            "你是校园外卖系统的智能助手，为用户推荐美食、解答点餐问题，并能帮用户【准备】下单购买、评价、退款、取消等操作。\n"
                    + "【最重要的安全规则】你【没有权限】直接完成下单、支付、退款、取消、评价等任何写操作。当你调用这类工具时，系统【不会】真正执行，而是生成一张『确认卡片』展示给用户，必须由用户在卡片上亲自点击确认后才会真正执行。因此你【绝对不能】说“已下单/已支付/已退款/已取消/已评价成功”之类的话，只能说“我已为你准备好下单卡片，请在下方确认”。\n"
                    + "你可以调用下列工具（参数为 JSON）：\n"
                    + "- search_shops{keyword}: 按关键字搜索营业中的店铺，返回店铺 id、名称、配送费、起送价。（只读）\n"
                    + "- list_dishes{shopId}: 查询某店铺在售菜品，返回菜品 id、名称、价格。（只读）\n"
                    + "- list_addresses{}: 查询当前用户的收货地址。（只读）\n"
                    + "- list_orders{status(可选,1待支付2待接单3待配送4配送中5已完成6已取消)}: 查询当前用户订单。（只读）\n"
                    + "- place_order{shopId, items:[{dishId, quantity}], addressId(可选), remark(可选)}: 生成『下单并支付』确认卡片；不填 addressId 时用默认地址。下单金额未达起送价时系统会自动补足数量，你【无需】因未达起送价反问用户；若返回里带 note，请把调整情况友好转告。\n"
                    + "- review_order{orderId 或 orderNo, rating(1-5), content}: 生成『评价订单』确认卡片。\n"
                    + "- refund_order{orderId 或 orderNo}: 生成『申请退款』确认卡片。\n"
                    + "- cancel_order{orderId 或 orderNo}: 生成『取消订单』确认卡片。\n"
                    + "  说明：用户报出的「订单号」即 orderNo，可直接作为 orderNo 传入，无需先查 orderId。\n\n"
                    + "【数据真实性】你没有任何内置的店铺、菜品、订单数据。凡涉及真实店铺、菜品、价格、订单的问题或操作，【绝对禁止】凭自己的知识回答或编造，必须先调用只读工具查询真实数据。例如用户问“有哪些奶茶店”，必须调用 search_shops，而不是列举你知道的品牌。\n\n"
                    + "调用协议（务必严格遵守）：\n"
                    + "1. 需要调用工具时，本轮回复【只能】是一个工具代码块，禁止任何解释、寒暄或“请稍等/我马上去做”之类的话。格式严格为：\n"
                    + "```tool\n{\"name\":\"工具名\",\"args\":{...}}\n```\n"
                    + "2. 不要描述你将要执行的步骤，直接输出第一步要调用的工具。系统会把结果以「工具返回: {...}」发回给你，你再据此决定下一步。\n"
                    + "3. 下单前若不知道 shopId / dishId，必须先 search_shops、list_dishes 查到真实 id，禁止编造 id。\n"
                    + "4. 写操作工具返回 {\"status\":\"need_confirm\",...} 时，表示确认卡片已生成，你【不要】再次调用该工具，应立即输出不含工具代码块的简体中文回复，告诉用户你已准备好卡片、请在下方确认（不要声称已完成）。\n"
                    + "5. 只有当无需再调用任何工具时，才输出不含工具代码块的简体中文回复，简洁友好。";

    /**
     * 运行一轮 Agent 对话。
     * @param dto    前端上传的多轮历史（user/assistant）
     * @param userId 当前登录用户（写操作的唯一可信身份来源）
     */
    public AgentReplyVO run(AiChatDTO dto, Long userId) {
        AgentReplyVO result = new AgentReplyVO();

        // 组装初始消息：系统提示词 + few-shot 示例（强约束小模型遵循工具协议） + 最近 10 条历史
        JSONArray messages = new JSONArray();
        messages.add(msg("system", SYSTEM_PROMPT));
        addFewShot(messages);
        if (!CollectionUtils.isEmpty(dto.getMessages())) {
            List<AiChatDTO.Message> history = dto.getMessages();
            int from = Math.max(0, history.size() - 10);
            for (int i = from; i < history.size(); i++) {
                AiChatDTO.Message m = history.get(i);
                if (m == null || m.getContent() == null || m.getContent().isBlank()) {
                    continue;
                }
                messages.add(msg("assistant".equals(m.getRole()) ? "assistant" : "user", m.getContent()));
            }
        }

        // ReAct 循环：模型 → 工具 → 回灌 → 模型 …
        for (int turn = 0; turn < MAX_TURNS; turn++) {
            String content = callModel(messages);
            JSONObject toolCall = extractTool(content);
            if (toolCall == null) {
                // 没有工具调用 = 最终自然语言答复
                result.setReply(content == null ? "" : content.trim());
                return result;
            }
            // 记录模型的工具调用，再把执行结果作为「用户消息」回灌，保持 user/assistant 交替
            messages.add(msg("assistant", content));
            String toolName = toolCall.getStr("name");
            JSONObject args = toolCall.getJSONObject("args");
            if (args == null) {
                args = new JSONObject();
            }
            String toolResult = executeTool(toolName, args, userId, result);
            messages.add(msg("user", "工具返回: " + toolResult));
        }

        // 兜底：超过最大轮数仍未收敛，给出温和提示
        result.setReply("抱歉，这个请求有点复杂，我没能完成。可以说得更具体一点吗？");
        return result;
    }

    /**
     * 注入一段「下单」全流程的 few-shot 示例对话：用真实的工具调用/回灌格式做示范，
     * 显著提升弱模型对工具协议的遵循度（避免它凭空作答或只描述步骤而不调用工具）。
     */
    private void addFewShot(JSONArray messages) {
        messages.add(msg("user", "有哪些奶茶店"));
        messages.add(msg("assistant", "```tool\n{\"name\":\"search_shops\",\"args\":{\"keyword\":\"奶茶\"}}\n```"));
        messages.add(msg("user", "工具返回: {\"shops\":[{\"id\":9001,\"name\":\"示例奶茶店\",\"deliveryFee\":2,\"minAmount\":15}]}"));
        messages.add(msg("assistant", "为你找到「示例奶茶店」（配送费¥2，起送¥15）。需要看看它家有哪些饮品吗？"));
        messages.add(msg("user", "买一杯它家的招牌奶茶"));
        messages.add(msg("assistant", "```tool\n{\"name\":\"list_dishes\",\"args\":{\"shopId\":9001}}\n```"));
        messages.add(msg("user", "工具返回: {\"dishes\":[{\"id\":8001,\"name\":\"招牌奶茶\",\"price\":12}]}"));
        messages.add(msg("assistant", "```tool\n{\"name\":\"place_order\",\"args\":{\"shopId\":9001,\"items\":[{\"dishId\":8001,\"quantity\":1}]}}\n```"));
        messages.add(msg("user", "工具返回: {\"status\":\"need_confirm\",\"summary\":\"示例奶茶店\\n招牌奶茶 x1\\n实付 ¥14.00\"}"));
        messages.add(msg("assistant", "我已为你准备好「招牌奶茶 x1」的下单卡片，实付 ¥14.00，请在下方卡片上点击确认后我再为你下单～"));
    }

    /** 调用大模型对话接口（与问答助手同款配置，密钥仅在后端） */
    private String callModel(JSONArray messages) {
        JSONObject body = new JSONObject();
        body.set("model", model);
        body.set("messages", messages);
        body.set("temperature", 0.3);
        body.set("max_tokens", maxTokens);
        body.set("stream", false);

        try (HttpResponse resp = HttpRequest.post(apiUrl)
                .header("Authorization", "Bearer " + apiPassword)
                .header("Content-Type", "application/json")
                .body(body.toString())
                .timeout(30000)
                .execute()) {
            String respBody = resp.body();
            if (!resp.isOk()) {
                throw new RuntimeException("AI 接口返回异常状态：" + resp.getStatus());
            }
            JSONObject json = JSONUtil.parseObj(respBody);
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

    /** 提取工具调用：优先匹配 ```tool ``` 代码块，其次兼容整段就是 {name,args} 的裸 JSON */
    private JSONObject extractTool(String content) {
        if (content == null || content.isBlank()) {
            return null;
        }
        Matcher m = TOOL_BLOCK.matcher(content);
        if (m.find()) {
            try {
                return JSONUtil.parseObj(m.group(1));
            } catch (Exception ignore) {
                return null;
            }
        }
        String t = content.trim();
        if (t.startsWith("{") && t.contains("\"name\"")) {
            try {
                JSONObject obj = JSONUtil.parseObj(t);
                return obj.containsKey("name") ? obj : null;
            } catch (Exception ignore) {
                return null;
            }
        }
        return null;
    }

    /**
     * 执行单个工具，返回字符串结果（JSON 或文案）回灌给模型。
     * 所有异常都转为 {"error":...} 返回，保证循环不中断、由模型向用户解释。
     */
    private String executeTool(String name, JSONObject args, Long userId, AgentReplyVO result) {
        try {
            if (name == null) {
                return err("未指定工具名");
            }
            switch (name) {
                case "search_shops":
                    return searchShops(args.getStr("keyword"));
                case "list_dishes":
                    return listDishes(args.getLong("shopId"));
                case "list_addresses":
                    return listAddresses(userId);
                case "place_order":
                    return placeOrder(args, userId, result);
                case "list_orders":
                    return listOrders(userId, args.getInt("status", null));
                case "review_order":
                    return reviewOrder(args, userId, result);
                case "refund_order":
                    return refundOrder(resolveOrderId(args, userId), userId, result);
                case "cancel_order":
                    return cancelOrder(resolveOrderId(args, userId), userId, result);
                default:
                    return err("未知工具: " + name);
            }
        } catch (BusinessException e) {
            return err(e.getMessage());
        } catch (Exception e) {
            return err("操作失败: " + e.getMessage());
        }
    }

    // ============ 各工具实现 ============

    private String searchShops(String keyword) {
        LambdaQueryWrapper<Shop> qw = new LambdaQueryWrapper<Shop>()
                .eq(Shop::getStatus, 1);
        if (keyword != null && !keyword.isBlank()) {
            qw.like(Shop::getName, keyword);
        }
        qw.orderByDesc(Shop::getSales).last("limit 10");
        List<Shop> shops = shopMapper.selectList(qw);
        JSONArray arr = new JSONArray();
        for (Shop s : shops) {
            JSONObject o = new JSONObject();
            o.set("id", s.getId());
            o.set("name", s.getName());
            o.set("deliveryFee", s.getDeliveryFee());
            o.set("minAmount", s.getMinAmount());
            arr.add(o);
        }
        if (arr.isEmpty()) {
            return err("没有找到匹配的店铺");
        }
        return new JSONObject().set("shops", arr).toString();
    }

    private String listDishes(Long shopId) {
        if (shopId == null) {
            return err("缺少 shopId");
        }
        List<Dish> dishes = dishMapper.selectList(new LambdaQueryWrapper<Dish>()
                .eq(Dish::getShopId, shopId)
                .eq(Dish::getStatus, 1)
                .orderByDesc(Dish::getSales)
                .last("limit 30"));
        JSONArray arr = new JSONArray();
        for (Dish d : dishes) {
            JSONObject o = new JSONObject();
            o.set("id", d.getId());
            o.set("name", d.getName());
            o.set("price", d.getPrice());
            arr.add(o);
        }
        if (arr.isEmpty()) {
            return err("该店铺暂无在售菜品");
        }
        return new JSONObject().set("dishes", arr).toString();
    }

    private String listAddresses(Long userId) {
        List<Address> list = addressMapper.selectList(new LambdaQueryWrapper<Address>()
                .eq(Address::getUserId, userId));
        JSONArray arr = new JSONArray();
        for (Address a : list) {
            JSONObject o = new JSONObject();
            o.set("id", a.getId());
            o.set("name", a.getName());
            o.set("phone", a.getPhone());
            o.set("detail", a.getDetail());
            o.set("isDefault", a.getIsDefault());
            arr.add(o);
        }
        if (arr.isEmpty()) {
            return err("用户还没有收货地址，请提示用户先去地址管理添加");
        }
        return new JSONObject().set("addresses", arr).toString();
    }

    private String placeOrder(JSONObject args, Long userId, AgentReplyVO result) {
        Long shopId = args.getLong("shopId");
        if (shopId == null) {
            return err("缺少 shopId");
        }
        JSONArray itemsJson = args.getJSONArray("items");
        if (itemsJson == null || itemsJson.isEmpty()) {
            return err("缺少购买的菜品 items");
        }
        List<OrderItemDTO> items = new ArrayList<>();
        for (int i = 0; i < itemsJson.size(); i++) {
            JSONObject it = itemsJson.getJSONObject(i);
            OrderItemDTO oi = new OrderItemDTO();
            oi.setDishId(it.getLong("dishId"));
            oi.setQuantity(Math.max(1, it.getInt("quantity", 1)));
            items.add(oi);
        }

        // 自动补足起送价：弱模型常只买 1 份最便宜的菜，导致低于起送价而下单失败。
        // 这里在下单前确定性地给「当前单价最低」的菜品逐份 +1，直到商品金额达到起送价，
        // 既贴近起送价（最小溢出），又让简单的自然语言下单（如「我想吃饭」）必然成功。
        String note = autoFillToMinAmount(shopId, items);

        // 收货地址：未指定则取默认地址，无默认则取第一个，仍无则提示用户先添加
        Long addressId = args.getLong("addressId");
        if (addressId == null) {
            List<Address> addrs = addressMapper.selectList(new LambdaQueryWrapper<Address>()
                    .eq(Address::getUserId, userId)
                    .orderByDesc(Address::getIsDefault));
            if (addrs.isEmpty()) {
                return err("用户没有收货地址，无法下单，请提示用户先添加收货地址");
            }
            addressId = addrs.get(0).getId();
        }

        // 不直接下单：核算金额与明细，生成「下单并支付」确认卡片，待用户在前端二次确认后由前端调用下单接口执行
        Shop shop = shopMapper.selectById(shopId);
        String shopName = shop == null ? "店铺" : shop.getName();

        StringBuilder summary = new StringBuilder(shopName).append('\n');
        BigDecimal goods = BigDecimal.ZERO;
        List<Map<String, Object>> payloadItems = new ArrayList<>();
        for (OrderItemDTO it : items) {
            Dish d = dishMapper.selectById(it.getDishId());
            if (d == null) {
                continue;
            }
            goods = goods.add(d.getPrice().multiply(BigDecimal.valueOf(it.getQuantity())));
            summary.append(d.getName()).append(" x").append(it.getQuantity()).append('\n');
            Map<String, Object> pi = new HashMap<>();
            pi.put("dishId", it.getDishId());
            pi.put("quantity", it.getQuantity());
            pi.put("dishName", d.getName());
            pi.put("price", d.getPrice());
            payloadItems.add(pi);
        }
        // 费用与下单接口保持一致：包装费 ¥1，免配送费(≤0)店铺按默认 ¥3 计
        BigDecimal packFee = new BigDecimal("1.0");
        BigDecimal deliveryFee = (shop == null || shop.getDeliveryFee() == null
                || shop.getDeliveryFee().compareTo(BigDecimal.ZERO) <= 0)
                ? new BigDecimal("3.0") : shop.getDeliveryFee();
        BigDecimal total = goods.add(packFee).add(deliveryFee);
        summary.append("实付 ¥").append(total.setScale(2, java.math.RoundingMode.HALF_UP));
        if (note != null) {
            summary.append('\n').append(note);
        }

        Map<String, Object> payload = new HashMap<>();
        payload.put("shopId", shopId);
        payload.put("addressId", addressId);
        payload.put("remark", args.getStr("remark"));
        payload.put("items", payloadItems);
        result.setProposal("place_order", "确认下单并支付", summary.toString(), payload);

        return new JSONObject().set("status", "need_confirm").set("summary", summary.toString()).toString();
    }

    /**
     * 下单前自动补足起送价：若商品金额低于店铺起送价，则给当前单价最低的菜品逐份 +1，
     * 直到达到起送价为止（最小溢出）。返回补足说明（用于回灌给模型告知用户）；未补足返回 null。
     * @param items 会被原地修改（增加对应菜品的 quantity）
     */
    private String autoFillToMinAmount(Long shopId, List<OrderItemDTO> items) {
        Shop shop = shopMapper.selectById(shopId);
        if (shop == null || shop.getMinAmount() == null) {
            return null;
        }
        BigDecimal minAmount = shop.getMinAmount();

        // 查出本单各菜品的真实单价与名称（信任服务端数据，不依赖模型传入价格）
        Map<Long, BigDecimal> priceMap = new HashMap<>();
        Map<Long, String> nameMap = new HashMap<>();
        for (OrderItemDTO it : items) {
            Dish d = dishMapper.selectById(it.getDishId());
            if (d != null) {
                priceMap.put(it.getDishId(), d.getPrice());
                nameMap.put(it.getDishId(), d.getName());
            }
        }

        BigDecimal goods = goodsAmount(items, priceMap);
        if (goods.compareTo(minAmount) >= 0) {
            return null;
        }

        // 找当前单价最低的可补足菜品
        OrderItemDTO cheapest = null;
        for (OrderItemDTO it : items) {
            BigDecimal p = priceMap.get(it.getDishId());
            if (p == null) {
                continue;
            }
            if (cheapest == null || p.compareTo(priceMap.get(cheapest.getDishId())) < 0) {
                cheapest = it;
            }
        }
        if (cheapest == null) {
            return null;
        }

        // 逐份 +1 直到达到起送价；安全上限防御死循环
        int guard = 0;
        while (goods.compareTo(minAmount) < 0 && guard < 200) {
            cheapest.setQuantity(cheapest.getQuantity() + 1);
            goods = goodsAmount(items, priceMap);
            guard++;
        }
        return "为达到起送价 ¥" + minAmount + "，已将「" + nameMap.get(cheapest.getDishId())
                + "」自动调整为 " + cheapest.getQuantity() + " 份";
    }

    /** 按服务端单价合计商品金额（缺价的菜品按 0 计，最终金额仍由 OrderService 重新核算） */
    private BigDecimal goodsAmount(List<OrderItemDTO> items, Map<Long, BigDecimal> priceMap) {
        BigDecimal sum = BigDecimal.ZERO;
        for (OrderItemDTO it : items) {
            BigDecimal p = priceMap.get(it.getDishId());
            if (p != null) {
                sum = sum.add(p.multiply(BigDecimal.valueOf(it.getQuantity())));
            }
        }
        return sum;
    }

    private String listOrders(Long userId, Integer status) {
        PageResult<OrderVO> page = orderService.userPage(userId, 1, 10, status);
        JSONArray arr = new JSONArray();
        for (OrderVO vo : page.getRecords()) {
            Orders o = vo.getOrder();
            JSONObject jo = new JSONObject();
            jo.set("orderId", o.getId());
            jo.set("orderNo", o.getOrderNo());
            jo.set("shopName", vo.getShopName());
            jo.set("status", o.getStatus());
            jo.set("statusText", statusText(o.getStatus()));
            jo.set("totalAmount", o.getTotalAmount());
            arr.add(jo);
        }
        if (arr.isEmpty()) {
            return err("没有符合条件的订单");
        }
        return new JSONObject().set("orders", arr).toString();
    }

    // 评价不直接落库：生成「评价订单」确认卡片，payload 携带 orderId/rating/content，待用户确认后由前端调用评价接口
    private String reviewOrder(JSONObject args, Long userId, AgentReplyVO result) {
        Long orderId = resolveOrderId(args, userId);
        if (orderId == null) {
            return err("缺少 orderId");
        }
        Orders order = ordersMapper.selectById(orderId);
        if (order == null || !userId.equals(order.getUserId())) {
            return err("订单不存在");
        }
        int rating = args.getInt("rating", 5);
        String content = args.getStr("content");
        String summary = "订单号 " + order.getOrderNo() + "\n评分 " + rating + " 星"
                + (content == null || content.isBlank() ? "" : "\n评价内容：" + content);
        Map<String, Object> payload = new HashMap<>();
        payload.put("orderId", orderId);
        payload.put("orderNo", order.getOrderNo());
        payload.put("rating", rating);
        payload.put("content", content);
        result.setProposal("review_order", "确认评价订单", summary, payload);
        return new JSONObject().set("status", "need_confirm").set("summary", summary).toString();
    }

    // 退款不直接执行：生成「申请退款」确认卡片，待用户确认后由前端调用退款接口
    private String refundOrder(Long orderId, Long userId, AgentReplyVO result) {
        if (orderId == null) {
            return err("缺少 orderId");
        }
        Orders order = ordersMapper.selectById(orderId);
        if (order == null || !userId.equals(order.getUserId())) {
            return err("订单不存在");
        }
        String summary = "订单号 " + order.getOrderNo() + "\n实付 ¥"
                + (order.getTotalAmount() == null ? "0.00" : order.getTotalAmount());
        Map<String, Object> payload = new HashMap<>();
        payload.put("orderId", orderId);
        payload.put("orderNo", order.getOrderNo());
        result.setProposal("refund_order", "确认申请退款", summary, payload);
        return new JSONObject().set("status", "need_confirm").set("summary", summary).toString();
    }

    // 取消不直接执行：生成「取消订单」确认卡片，待用户确认后由前端调用取消接口
    private String cancelOrder(Long orderId, Long userId, AgentReplyVO result) {
        if (orderId == null) {
            return err("缺少 orderId");
        }
        Orders order = ordersMapper.selectById(orderId);
        if (order == null || !userId.equals(order.getUserId())) {
            return err("订单不存在");
        }
        String summary = "订单号 " + order.getOrderNo() + "\n当前状态：" + statusText(order.getStatus());
        Map<String, Object> payload = new HashMap<>();
        payload.put("orderId", orderId);
        payload.put("orderNo", order.getOrderNo());
        result.setProposal("cancel_order", "确认取消订单", summary, payload);
        return new JSONObject().set("status", "need_confirm").set("summary", summary).toString();
    }

    /**
     * 解析订单标识：用户常用「订单号(orderNo)」指代订单，而模型可能误把它当作内部 id 传入。
     * 这里同时兼容 orderId 与 orderNo：先按内部 id 命中，未命中再按订单号在【当前用户】订单中查找，避免越权。
     */
    private Long resolveOrderId(JSONObject args, Long userId) {
        Long orderId = args.getLong("orderId");
        if (orderId != null && ordersMapper.selectById(orderId) != null) {
            return orderId;
        }
        String orderNo = args.getStr("orderNo");
        if ((orderNo == null || orderNo.isBlank()) && orderId != null) {
            orderNo = String.valueOf(orderId);
        }
        if (orderNo != null && !orderNo.isBlank()) {
            Orders o = ordersMapper.selectOne(new LambdaQueryWrapper<Orders>()
                    .eq(Orders::getOrderNo, orderNo)
                    .eq(Orders::getUserId, userId)
                    .last("limit 1"));
            if (o != null) {
                return o.getId();
            }
        }
        return orderId;
    }

    // ============ 工具方法 ============

    private JSONObject msg(String role, String content) {
        return new JSONObject().set("role", role).set("content", content);
    }

    private String err(String message) {
        return new JSONObject().set("error", message).toString();
    }

    private String statusText(Integer s) {
        if (s == null) return "";
        switch (s) {
            case 1: return "待支付";
            case 2: return "待接单";
            case 3: return "待配送";
            case 4: return "配送中";
            case 5: return "已完成";
            case 6: return "已取消";
            default: return "";
        }
    }
}
