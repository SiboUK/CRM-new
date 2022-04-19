package com.chengsibo.crm.settings.service;

import com.chengsibo.crm.settings.domain.User;

import java.util.List;
import java.util.Map;

public interface UserService {
    User queryUserByLoginActAndPwd(Map map);
    List<User> queryAllUsers();
}
