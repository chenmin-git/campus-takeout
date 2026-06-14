package com.campus.takeout.interceptor;

import com.campus.takeout.common.JwtUtil;
import com.campus.takeout.common.UserContext;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 登录拦截器：校验请求头中的 token，解析出当前用户写入 UserContext。
 * 校验失败返回 401，未登录的公开接口（登录/注册/静态资源）在 WebMvcConfig 中放行。
 */
@Component
public class LoginInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String token = request.getHeader("token");
        if (token == null || token.isEmpty()) {
            token = request.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
            }
        }
        if (token == null || token.isEmpty()) {
            response.setStatus(401);
            return false;
        }
        try {
            Claims claims = jwtUtil.parse(token);
            Long userId = claims.get("userId", Long.class);
            String role = claims.get("role", String.class);
            UserContext.set(userId, role);
            return true;
        } catch (Exception e) {
            // token 非法或过期
            response.setStatus(401);
            return false;
        }
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        // 请求结束清理 ThreadLocal，避免线程复用导致用户串号
        UserContext.clear();
    }
}
