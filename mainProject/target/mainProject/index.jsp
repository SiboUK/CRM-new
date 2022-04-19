<!DOCTYPE HTML>
<%@ page language="java"  contentType="text/html; charset=utf-8" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + 	request.getServerPort() + request.getContextPath() + "/";
%>
<html>
<head>
    <base href="<%=basePath%>">
    <meta charset="UTF-8">
    <title>测试页面</title>
</head>
<body>
<%
    request.setCharacterEncoding("utf-8");
%>
$.ajax({
url:"",
data:{},
type:"",
dataType:"",
success:function (data) {

}
})

</body>

</html>

