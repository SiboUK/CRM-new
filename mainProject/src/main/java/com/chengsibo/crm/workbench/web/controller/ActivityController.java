package com.chengsibo.crm.workbench.web.controller;

import com.chengsibo.crm.commons.constants.ReturnObjectStatus;
import com.chengsibo.crm.commons.utils.DateFormat;
import com.chengsibo.crm.commons.utils.UUIDUtil;
import com.chengsibo.crm.commons.vo.ReturnObject;
import com.chengsibo.crm.settings.domain.User;
import com.chengsibo.crm.settings.service.UserService;
import com.chengsibo.crm.workbench.domain.Activity;
import com.chengsibo.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Controller
public class ActivityController {
    @Autowired
    UserService userService;
    @Autowired
    ActivityService activityService;

    @RequestMapping("/workbench/activity/index")
    public String index(HttpServletRequest request){
        List<User> users = userService.queryAllUsers();
        request.setAttribute("users",users);
        return "workbench/activity/index";
    }

    /*
    * 一般情况下:在controller层从service层查出来的数据我们不考虑是否有异常，因为基本不可能出现异常。他只是查看。
	* 但是如果是增删改的话与可能会影响到别的数据，有异常的概率会大一些。所以我们要考虑异常，而且在springmvc中
	* 事务回滚以后，还会把异常上抛给controller层。所以需要try catch。
    * */
    @RequestMapping("/workbench/activity/createActivity")
    @ResponseBody
    public Object createActivity(Activity activity, HttpSession session){
        activity.setId(UUIDUtil.generate());
        User user = (User) session.getAttribute(ReturnObjectStatus.USER_SESSION);
        activity.setCreateBy(user.getId());
        activity.setCreateTime(DateFormat.dateTime2String(new Date()));
        ReturnObject ro = new ReturnObject();
        try{
            int no = activityService.saveCreateActivity(activity);
            if(no==0){
                ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_FAIL);
                ro.setMessage("网络繁忙，请稍后再试验");
            }else{
                ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_SUCCESS);
            }
        } catch (Exception e){
            e.printStackTrace();
            ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_FAIL);
            ro.setMessage("网络繁忙，请稍后再试验");
        }
        return ro;
    }

    @RequestMapping("/workbench/activity/showActivity")
    @ResponseBody
    public Object showActivity(String name, String owner, String startDate, String endDate, int pageNo, int pageSize){
        Map<String, Object> map = new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate", startDate);
        map.put("endDate", endDate);
        map.put("beginNo", (pageNo-1)*pageSize);
        map.put("pageSize", pageSize);
        List<Activity> activityList = activityService.queryActivityConditionForPage(map);
        int count = activityService.queryCountOfActivityByCondition(map);
        Map<String, Object> obj = new HashMap<>();
        obj.put("activityList",activityList);
        obj.put("count",count);
        return obj;
    }

    @RequestMapping("/workbench/activity/deleteActivityByIds")
    @ResponseBody
    public Object deleteActivityByIds(String[] id){ // 注意这里的名字要和传过来的id=xxx&id=xxx的这个属性名相同
        ReturnObject ro = new ReturnObject();
        try{
            int ret = activityService.deleteActivityByIds(id);
            if(ret!=0){
                ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_SUCCESS);
            }else{
                ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_FAIL);
                ro.setMessage("请稍后尝试");
            }
        } catch (Exception e){
            ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_FAIL);
            ro.setMessage("请稍后尝试");
        }
        return ro;
    }

    @RequestMapping("/workbench/activity/queryActivityById")
    @ResponseBody
    public Object queryActivityById(String id){
        Activity activity = activityService.queryActivityById(id);
        return activity;
    }

    @RequestMapping("/workbench/activity/editActivityById")
    @ResponseBody
    public Object editActivityById(Activity activity, HttpSession session){
        activity.setEditBy(DateFormat.dateTime2String(new Date()));
        User user = (User)session.getAttribute(ReturnObjectStatus.USER_SESSION);
        activity.setEditBy(user.getId());
        ReturnObject ro = new ReturnObject();
        try{
            int ret = activityService.editActivityById(activity);
            if(ret>0){
                ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_SUCCESS);
            }else{
                ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_FAIL);
                ro.setMessage("请稍后尝试");
            }
        }catch (Exception e){
            ro.setCode(ReturnObjectStatus.RETURN_OBJECT_STATUS_FAIL);
            ro.setMessage("请稍后尝试");
        }
        return ro;
    }

    @RequestMapping("/workbench/activity/exportActivitiesDownload")
    public void exportActivitiesDownload(HttpServletResponse response) throws IOException {
        // 查询所有的活动列表数据
        List<Activity> aList = activityService.queryAllActivities();
        // 调用poi实现java生成excel文件
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("activities");
        HSSFRow row = sheet.createRow(0); // 从0行开始
        // 完成第一行的数据
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("ID");
        cell = row.createCell(1);
        cell.setCellValue("所有者");
        cell = row.createCell(2);
        cell.setCellValue("名称");
        cell = row.createCell(3);
        cell.setCellValue("开始日期");
        cell = row.createCell(4);
        cell.setCellValue("结束日期");
        cell = row.createCell(5);
        cell.setCellValue("成本");
        cell = row.createCell(6);
        cell.setCellValue("描述");
        cell = row.createCell(7);
        cell.setCellValue("创建时间");
        cell = row.createCell(8);
        cell.setCellValue("创建人");
        cell = row.createCell(9);
        cell.setCellValue("编辑时间");
        cell = row.createCell(10);
        cell.setCellValue("编辑人");
        // 开始完成每一行数据的填写
        Activity ac = null;
        for(int i=0; i<aList.size(); i++){
            ac = aList.get(i);
            row = sheet.createRow(i+1);
            cell = row.createCell(0);
            cell.setCellValue(ac.getId());
            cell = row.createCell(1);
            cell.setCellValue(ac.getOwner());
            cell = row.createCell(2);
            cell.setCellValue(ac.getName());
            cell = row.createCell(3);
            cell.setCellValue(ac.getStartDate());
            cell = row.createCell(4);
            cell.setCellValue(ac.getEndDate());
            cell = row.createCell(5);
            cell.setCellValue(ac.getCost());
            cell = row.createCell(6);
            cell.setCellValue(ac.getDescription());
            cell = row.createCell(7);
            cell.setCellValue(ac.getCreateTime());
            cell = row.createCell(8);
            cell.setCellValue(ac.getCreateBy());
            cell = row.createCell(9);
            cell.setCellValue(ac.getEditTime());
            cell = row.createCell(10);
            cell.setCellValue(ac.getEditBy());
        }

        // 这个表示返回的是excel文件，每种文件都有不一样的这个类型
        response.setContentType("application/octet-stream;charset=utf-8");

        // 这个是为了保证浏览器接收到文件去下载，而不是直接显示在浏览器。并且能够设置返回文件的名字。
        response.addHeader("Content-Disposition","attachment;filename=activityList.xls");

        // 使用输入输出流会抛异常的，这里我们选择直接抛，因为就算try。。catch你也不能
        // 往客户端写这个数据，因为返回去的时候浏览器会根据content-type解析文件，没地方返回这个信息。所以直接上抛就行了。
        OutputStream os = response.getOutputStream();
        //按照字节流的方式写会浏览器。
        wb.write(os);
        // 释放所有创建excel在内存中的对象
        wb.close();
        os.flush();
    }



}
