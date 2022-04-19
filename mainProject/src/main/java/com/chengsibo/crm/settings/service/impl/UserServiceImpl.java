package com.chengsibo.crm.settings.service.impl;

import com.chengsibo.crm.settings.domain.User;
import com.chengsibo.crm.settings.mapper.UserMapper;
import com.chengsibo.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service("userService")
public class UserServiceImpl implements UserService {
    @Autowired
    UserMapper userMapper;

    @Override
    public User queryUserByLoginActAndPwd(Map map) {
        return userMapper.selectUserByLoginActAndPwd(map);
    }

    @Override
    public List<User> queryAllUsers() {
        return userMapper.selectAllUsers();
    }
}
