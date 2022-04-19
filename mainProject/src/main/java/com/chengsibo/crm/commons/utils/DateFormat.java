package com.chengsibo.crm.commons.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

public class DateFormat {

    private DateFormat() {
    }

    public static String dateTime2String(Date date){
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH-mm-ss");
        return sdf.format(date);
    }

    public static String date2String(Date date){
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(date);
    }

}
