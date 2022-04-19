package com.chengsibo.crm.commons.utils;

import java.util.Date;
import java.util.UUID;

public class UUIDUtil {
    public static String generate(){
        return UUID.randomUUID().toString().replaceAll("-","");
    }
}
