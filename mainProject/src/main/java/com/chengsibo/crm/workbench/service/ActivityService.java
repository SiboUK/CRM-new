package com.chengsibo.crm.workbench.service;

import com.chengsibo.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

public interface ActivityService {
    int saveCreateActivity(Activity activity);
    List<Activity> queryActivityConditionForPage(Map<String, Object> map);
    int queryCountOfActivityByCondition(Map<String, Object> map);
    int deleteActivityByIds(String[] ids);
    Activity queryActivityById(String id);
    int editActivityById(Activity activity);
    List<Activity> queryAllActivities();
    int saveActivityByFile(List<Activity> activities);
}
