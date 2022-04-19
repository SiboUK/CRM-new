<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + 	request.getServerPort() + request.getContextPath() + "/";
%>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript">
		$(function () {
			$(window).keydown(function (e) { // 使用window的jquery对象是为了保证在浏览器页面上只要摁键盘就会触发这个方法。
				//alert(e.keyCode);
				if(e.keyCode==13){
					$("#loginBtn").click(); // 触发绑定事件。
				}
			})

			$("#loginBtn").click(function () {
				var loginAct = $.trim($("#username").val());
				var loginPwd = $.trim($("#password").val());
				var isRemPwd = $("#isRemPsw").prop("checked");
				if(loginAct==""){
					alert("输入账户名");
					return;
				}
				if(loginPwd==""){
					alert("输入密码");
					return;
				}
				$.ajax({
					url:"settings/qx/user/login",
					data:{
						"loginAct":loginAct,
						"loginPwd":loginPwd,
						"isRemPwd":isRemPwd
					},
					type:"post",
					dataType:"json",
					success:function (data) {
						if(data.code==1){
							window.location.href="workbench/index";
						}else{
							$("#msg").text(data.message);
						}
					},
					beforeSend:function () {
						/*
						* 当ajax向后台发送请求之间，会自动执行本函数，
						* 如果该函数的返回值为true，则ajax会向后台发送请求，如果该函数返回false，则ajax不会向后台发送请求。有些人会把数据验证放在这里。
						* */
						$("#msg").text("请稍后...");
						
					}
				})
			})

		});
	</script>
</head>
<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2019&nbsp;动力节点</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="workbench/index.html" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" id="username" type="text" value="${cookie.loginAct.value}" placeholder="用户名">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" id="password" type="password" value="${cookie.loginPwd.value}" placeholder="密码">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">
						<label>
							<c:if test="${not empty cookie.loginAct and not empty cookie.loginPwd}">
								<input type="checkbox" id="isRemPsw" checked>
							</c:if>
							<c:if test="${empty cookie.loginAct or empty cookie.loginPwd}">
								<input type="checkbox" id="isRemPsw">
							</c:if>
							十天内免登录
						</label>
						&nbsp;&nbsp;
						<span id="msg"></span>
					</div>
					<button type="button" id="loginBtn" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>