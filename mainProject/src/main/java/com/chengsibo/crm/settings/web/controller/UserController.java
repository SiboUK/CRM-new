package com.chengsibo.crm.settings.web.controller;

import com.chengsibo.crm.commons.constants.ReturnObjectStatus;
import com.chengsibo.crm.commons.utils.DateFormat;
import com.chengsibo.crm.commons.vo.ReturnObject;
import com.chengsibo.crm.settings.domain.User;
import com.chengsibo.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Controller
public class UserController {
    @Autowired
    UserService userService;
    /*
    * 这样命名url是有说法的，是按照返回的jsp页面的路径来写的url。但是不是完全一样，否则就和资源路径重复了，最后改成方法名。
    * */
    @RequestMapping("/settings/qx/user/toLogin")
    public String toLogin(){
        return "settings/qx/user/login";
    }

    @RequestMapping("/settings/qx/user/login")
    @ResponseBody
    public Object login(String loginAct, String loginPwd, String isRemPwd, HttpServletResponse response, HttpServletRequest request, HttpSession session){
        Map<String, Object> map = new HashMap<>();
        map.put("loginAct", loginAct);
        map.put("loginPwd", loginPwd);
        User user = userService.queryUserByLoginActAndPwd(map);
        ReturnObject ro = new ReturnObject();
        if(user==null){
            // code:0 message:"用户名或者密码错误"
            ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_FAIL);
            ro.setMessage("用户名或者密码错误");
        }else{
            if(!user.getAllowIps().contains(request.getRemoteAddr())){
                // code:0 message:"ip受限"
                ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_FAIL);
                ro.setMessage("ip受限");
            }else if(DateFormat.dateTime2String(new Date()).compareTo(user.getExpireTime())>0){
                // code:0 message:"账户已过时"
                ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_FAIL);
                ro.setMessage("账户已过时");
            }else if("0".equals(user.getLockState())){
                // code:0 message:"账户已锁定"
                ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_FAIL);
                ro.setMessage("账户已锁定");
            }else{
                // code:1
                ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_SUCCESS);
                // 登录成功，将用户放到session作用域中
                session.setAttribute(ReturnObjectStatus.USER_SESSION,user);
                // 登陆成功，判断是否需要将账户密码放到cookie中。
                if("true".equals(isRemPwd)){
                    Cookie c1 = new Cookie("loginAct", user.getLoginAct());
                    c1.setMaxAge(10*24*60*60);// 单位为秒
                    response.addCookie(c1);
                    Cookie c2 = new Cookie("loginPwd", user.getLoginPwd());
                    c2.setMaxAge(10*24*60*60);// 单位为秒
                    response.addCookie(c2);
                }else{
                    // 如果不需要了，则删除之前保存的，或者之前没保存，那么也没有影响。
                    // 从服务器是没有办法访问浏览器的文件去删除cookie的，但是由于同名的cookie会进行覆盖，所以
                    // 将同名的cookie覆盖了，并且将它的存活时间设置为0，那么就能到达删除原先cookie的目的。
                    Cookie c1 = new Cookie("loginAct", "1");
                    c1.setMaxAge(0);// 单位为秒
                    response.addCookie(c1);
                    Cookie c2 = new Cookie("loginPwd", "1");
                    c2.setMaxAge(0);// 单位为秒
                    response.addCookie(c2);
                }
            }
        }
        return ro;
    }
    @RequestMapping("/settings/qx/user/logout")
    public String logout(HttpServletResponse response, HttpSession session){
        // 删除cookies
        Cookie c1 = new Cookie("loginAct", "1");
        c1.setMaxAge(0);// 单位为秒
        response.addCookie(c1);
        Cookie c2 = new Cookie("loginPwd", "1");
        c2.setMaxAge(0);// 单位为秒
        response.addCookie(c2);
        // 删除session以及当中保存的数据
        session.invalidate();
        return "redirect:/";  // 这里使用spring框架，底层调用了httpServletResponse.sendRedirect(/项目名/)，默认把项目名给加上了。所以直接写资源名就行。
    }

}
