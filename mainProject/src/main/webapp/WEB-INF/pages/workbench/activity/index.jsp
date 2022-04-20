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
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script> <%--js的包导入的时候先导入被依赖的包，否则插件不起作用--%>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>


<script type="text/javascript">

	$(function(){

		// 点击修改按钮，弹出模态窗口
		$("#saveEditActivityBtn").click(function () {
			var $checkedBox = $("#showActivityBody input[type='checkbox']:checked");
			if($checkedBox.size()==0){
				alert("请选择编辑对象");
				return;
			}
			if($checkedBox.size()>1){
				alert("只能选择一个对象");
				return;
			}
			var id = $checkedBox.val();
			$.ajax({
				url:'workbench/activity/queryActivityById',
				data:{
					id:id
				},
				type:"post",
				dataType:'json',
				success:function (data) {
					$("#editActivityId").val(data.id);
					$("#edit-marketActivityOwner").val(data.owner);
					$("#edit-marketActivityName").val(data.name);
					$("#edit-startTime").val(data.startDate);
					$("#edit-endTime").val(data.endDate);
					$("#edit-cost").val(data.cost);
					$("#edit-description").val(data.description);
					$("#editActivityModal").modal("show");
				}
			})
		})
		// 更新活动
		$("#updateActivityBtn").click(function () {
			// 收集信息
			var id = $("#editActivityId").val();
			var owner = $("#edit-marketActivityOwner").val();
			var name = $.trim($("#edit-marketActivityName").val());
			var startDate = $("#edit-startTime").val();
			var endDate = $("#edit-endTime").val();
			var cost = $.trim($("#edit-cost").val());
			var description = $.trim($("#edit-description").val());
			// 检查信息
			if(name==""){
				alert("请添加名称");
				return;
			}
			if(startDate!=""&endDate!=""){
				if(startDate>endDate){
					alert("结束时间不能小于开始时间");
					return;
				}
			}
			var regExp = /^(([1-9]\d*)|0)$/;
			if(!regExp.test(cost)){
				alert("成本为非负整数");
				return;
			}
			$.ajax({
				url:'workbench/activity/editActivityById',
				data:{
					id:id,
					owner:owner,
					name:name,
					startDate:startDate,
					endDate:endDate,
					cost:cost,
					description:description
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if(data.code=='1'){
						// 关闭模态窗口
						$("#editActivityModal").modal("hide");
						// 发送更新请求
						queryActivityByConditionForPage($("#pagination").bs_pagination('getOption','currentPage'),$("#pagination").bs_pagination("getOption", "rowsPerPage"))
					}else{
						alert(data.message);
					}
				}
			})


		})
		// 删除所勾选的活动列表
		$("#deleteActivityBtn").click(function () {
			if($("#showActivityBody input[type='checkbox']:checked").size()==0){
				alert("请选择删除的活动");
				return;
			}
			var ids="";
			$.each($("#showActivityBody input[type='checkbox']:checked"),function () {
				ids += "id="+this.value+"&";
			})
			ids = ids.substr(0,ids.length-1);
			$.ajax({
				url:"workbench/activity/deleteActivityByIds",
				data:ids,
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.code==1){
						queryActivityByConditionForPage(1, $("#pagination").bs_pagination("getOption", "rowsPerPage"));
					}else{
						alert(data.message);
					}
				}
			})
		})



		//	框全选和不全选的代码
		$("#checkAllBtn").click(function () {
			// 父子选择器， 前面是父选择器，如果是直系的父选择器，则加‘>’ ，但是这个不是，则用空格，表示父标签下所有的子标签中找满足条件的子标签
			$("#showActivityBody input[type='checkbox']").prop("checked",this.checked);
		})

		$("#showActivityBody").on("click", "input[type='checkbox']", function () {
			if($("#showActivityBody input[type='checkbox']").size()==$("#showActivityBody input[type='checkbox']:checked").size()){
				$("#checkAllBtn").prop("checked",true);
			}else{
				$("#checkAllBtn").prop("checked",false);
			}
		})

		queryActivityByConditionForPage(1,10);

		$("#searchActivityByConditionBtn").click(function () {
			// $("#pagination").bs_pagination("getOption", "rowsPerPage") 通过这个函数可以获得分页对象的属性。
			queryActivityByConditionForPage(1,$("#pagination").bs_pagination("getOption", "rowsPerPage"));
		})

		$(".myDate").datetimepicker({		// 调用这个方法就自动绑定了click事件。
			language:'zh-CN', // 语言
			format:'yyyy-mm-dd', // 日期的形式
			minView:'month', // 可以选择的最小视图。
			initData:new Date(), // 初始化显示的日期
			autoclose:true, // 设置选择完日期或者时间之后，是否自动关闭
			todayBtn:true, // 设置是否显示‘今天’的按钮，默认为false
			clearBtn:true //  设置是否显示‘清空’的按钮，默认为false
		});

		$("#createActivityBtn").click(function () {
			// 重置表单
			$("#createActivityForm")[0].reset(); // reset函数是dom对象的函数，直接用jquery对象不行。

			$("#createActivityModal").modal("show");
		})
		
		$("#saveActivity").click(function () {
			// 收集所有的信息
			var owner = $("#create-marketActivityOwner").val();
			var activityName = $.trim($("#create-marketActivityName").val());
			var startTime = $("#create-startTime").val();
			var endTime = $("#create-endTime").val();
			var cost = $.trim($("#create-cost").val());
			var description = $.trim($("#create-describe").val());
			// 表单验证
			if(owner==""){
				alert("所有者不能为空");
				return;
			}
			if(activityName==""){
				alert("活动名称不能为空");
				return;
			}
			if(startTime!=""&&endTime!=""){
				if(startTime>endTime){
					alert("结束时间不能小于开始时间");
					return;
				}
			}
			var regExp = /^(([1-9]\d*)|0)$/;
			if(!regExp.test(cost)){
				alert("成本为非负整数");
				return;
			}

			// 发送ajax请求
			$.ajax({
				url:"workbench/activity/createActivity",
				data:{
					owner:owner,
					name:activityName,
					startDate:startTime,
					endDate:endTime,
					cost:cost,
					description:description
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if(data.code=="1"){
						$("#createActivityModal").modal("hide");
						// 添加成功以后保证pageSize不变的基础上刷新到第一页
						queryActivityByConditionForPage(1,$("#pagination").bs_pagination("getOption", "rowsPerPage"));
					}else{
						alert(data.message);
					}
				}
			})
		})

		$("#exportActivityAllBtn").click(function () {
			window.location.href="workbench/activity/exportActivitiesDownload"; // 不能使用ajax
		})

		$("#importActivityBtn").click(function () {
			var fileName=$("#activityFile").val();
			if(fileName.length==0){
				alert("请选择上传文件");
				return;
			}
			var suffix=fileName.substr(fileName.lastIndexOf(".")+1).toLowerCase();
			if(suffix!="xls"){
				alert("请上传xml文件");
				return;
			}
			var file=$("#activityFile").get(0).files[0]; // 取到被上传的文件的对象,files属性是一个数组，所以选择第一个.
			if(file.size>5*1024*1024){
				alert("文件要小于5MB");
				return;
			}
			var formData = new FormData(); // 这个对象不仅可以传输文本数据，也可以传输二进制数据。
			formData.append("activityFile",file);
			$.ajax({
				url:"workbench/activity/importActivityByFile",
				data:formData,
				type:"post",
				dataType:"json",
				processData:false, // 设置ajax向后台提交参数之前，是否把参数统一转换成字符串，true--是，flase--不是，默认为true
				contentType:false, // 设置ajax向后台提交参数之前，是否把所有的参数按照urlencoded编码，true--是，flase--不是，默认为true
				success:function (data) {
					// 说明上传成功
					if(data.code=='1'){
						alert(data.other);
						queryActivityByConditionForPage(1,$("#pagination").bs_pagination("getOption", "rowsPerPage"));
						$("#importActivityModal").modal("hide");
					}else{
						alert(data.message);
					}
				}
			})
		})


	});
	
	function queryActivityByConditionForPage(pageNo, pageSize) {
		var name = $("#create-name").val();
		var owner = $("#create-owner").val();
		var startDate = $("#startDate").val();
		var endDate = $("#startDate").val();
		// 查询不需要表单检验，直接发送请求就好了。
		$.ajax({
			url:'workbench/activity/showActivity',
			data:{
				name:name,
				owner:owner,
				startDate:startDate,
				endDate:endDate,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:'post',
			dataType: 'json',
			success:function (data) {
				var html="";
				$.each(data.activityList,function (i,obj) {
					html+="<tr class=\"active\">";
					html+="<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>";
					html+="<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='detail.html';\">"+obj.name+"</a></td>";
					html+="<td>"+obj.owner+"</td>";
					html+="<td>"+obj.startDate+"</td>";
					html+="<td>"+obj.endDate+"</td>";
					html+="</tr>";
				})
				$("#showActivityBody").html(html);

				// 每次刷新，将总选框的对钩去掉
				$("#checkAllBtn").prop("checked",false);

				// 计算总页数
				var totalPages=1;
				if(data.count%pageSize==0){
					totalPages=data.count/pageSize;
				}else{
					totalPages=parseInt(data.count/pageSize)+1;
				}

				// 调用分页函数,容器展示分页的界面
				$("#pagination").bs_pagination({
					currentPage:pageNo, // 当前页号，相当于pageNo，会根据用户选择而更新这个属性

					rowsPerPage:pageSize, // 每页显示行数，相当于pageSize,会根据用户选择而更新这个属性
					totalPages:totalPages, // 总页数，必填参数
					totalRows:data.count, // 总条数 以上这三个参数必须保证对应关系

					visiblePageLinks: 10, // 最多显示的小卡片个数
					showGoToPage: true, // 是否显示‘跳转到’部分，默认是true
					showRowsPerPage: true, // 是否显示每页显示条数部分，默认是true
					showRowsInfo: true, // 是否显示记录的信息，默认true，显示

					// 用户每次切换页号，都会自动出发该函数
					// 每次返回页号改变之后的页号和每个显示个数
					// 注意这个不是死循环，因为下面是点击了才会调用。
					onChangePage:function (event, pageObj) { // returns page_num and rows_per_page after a link is clicked
						queryActivityByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
					}
				})

			}
		})
	}
	
</script>
</head>
<body>
	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog"> <%--jQuery会将带有modal fade属性的标签作为模态窗口。--%>
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" id="createActivityForm" role="form">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
								  <c:forEach items="${requestScope.users}" var="u">
									  <option value="${u.id}">${u.name}</option>
								  </c:forEach>
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control myDate" id="create-startTime">
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control myDate" id="create-endTime">
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveActivity">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
						<input type="hidden" id="editActivityId">
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
									<c:forEach items="${requestScope.users}" var="u">
										<option value="${u.id}">${u.name}</option>
									</c:forEach>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control myDate" id="edit-startTime">
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control myDate" id="edit-endTime">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateActivityBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 导入市场活动的模态窗口 -->
    <div class="modal fade" id="importActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
                </div>
                <div class="modal-body" style="height: 350px;">
                    <div style="position: relative;top: 20px; left: 50px;">
                        请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                    </div>
                    <div style="position: relative;top: 40px; left: 50px;">
                        <input type="file" id="activityFile">
                    </div>
                    <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;" >
                        <h3>重要提示</h3>
                        <ul>
                            <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                            <li>给定文件的第一行将视为字段名。</li>
                            <li>请确认您的文件大小不超过5MB。</li>
                            <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                            <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                            <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                            <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
                </div>
            </div>
        </div>
    </div>
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="create-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="create-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="endDate">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchActivityByConditionBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createActivityBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="saveEditActivityBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteActivityBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				<div class="btn-group" style="position: relative; top: 18%;">
                    <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal" ><span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）</button>
                    <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）</button>
                    <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）</button>
                </div>
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAllBtn" /></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="showActivityBody">
						<%--<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			<div id="pagination"></div>
			<%--<div style="height: 50px; position: relative;top: 30px;">
				<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b id="countOfActivity">50</b>条记录</button>
				</div>
				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">
					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
				</div>
				<div style="position: relative;top: -88px; left: 285px;">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">首页</a></li>
							<li class="disabled"><a href="#">上一页</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">下一页</a></li>
							<li class="disabled"><a href="#">末页</a></li>
						</ul>
					</nav>
				</div>
			</div>--%>
			
		</div>
		
	</div>
</body>
</html>