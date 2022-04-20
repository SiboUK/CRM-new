package com.chengsibo.crm.commons.utils;

import org.apache.poi.hssf.usermodel.HSSFCell;

public class HSSFCellUtils {
    private HSSFCellUtils() {
    }

    public static String getCellValueForStr(HSSFCell cell){
        String ret="";
        if (cell.getCellType()==HSSFCell.CELL_TYPE_NUMERIC){
            ret=cell.getNumericCellValue()+"";
        }else if(cell.getCellType()==HSSFCell.CELL_TYPE_FORMULA){
            ret=cell.getCellFormula();
        }else if(cell.getCellType()==HSSFCell.CELL_TYPE_BOOLEAN){
            ret=cell.getCellFormula()+"";
        }else if(cell.getCellType()==HSSFCell.CELL_TYPE_STRING){
            ret=cell.getStringCellValue();
        }else{
            ret="";
        }
        return ret;
    }
}
