package com.chengsibo.crm.web.interceptor;

import com.chengsibo.crm.commons.constants.ReturnObjectStatus;
import com.chengsibo.crm.settings.domain.User;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class LoginInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o) throws Exception {
        HttpSession session = httpServletRequest.getSession();
        User user = (User) session.getAttribute(ReturnObjectStatus.USER_SESSION);
        if(user==null){
            httpServletResponse.sendRedirect(httpServletRequest.getContextPath()); // 这里要注意：框架手动调用重定向的时候要写项目名，手动请求转发则不需要。这里httpServletRequest.getContextPath() == “/crm”
            return false;
        }
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o, ModelAndView modelAndView) throws Exception {

    }

    @Override
    public void afterCompletion(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o, Exception e) throws Exception {

    }
}
