package com.chengsibo.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class WorkBenchController {
    @RequestMapping("/workbench/index")
    public String index(){
        System.out.println("111");
        return "workbench/index";
    }
}
