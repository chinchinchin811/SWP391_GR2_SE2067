<%@page import="java.util.List,model.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
List<LearningMaterial> materials=(List<LearningMaterial>)request.getAttribute("materials");
List<TrainingClass> classes=(List<TrainingClass>)request.getAttribute("classes");
User me=(User)session.getAttribute("currentUser"); boolean manage=me!=null&&me.getRoleId()<=3;
%>
<jsp:include page="/views/common/header.jsp"/>
<jsp:include page="/views/common/sidebar.jsp"/>
<main class="main-content"><div class="content-body materials-page">
  <section class="materials-hero">
    <div><span class="eyebrow">TRUNG TÂM ĐÀO TẠO</span><h1>Học liệu của bạn</h1><p>Đọc tài liệu, xem slide và học video ngay trên trình duyệt.</p></div>
    <%if(manage){%><a class="btn btn-primary" href="<%=request.getContextPath()%>/materials?action=create">+ Thêm học liệu</a><%}%>
  </section>
  <%if(session.getAttribute("successMessage")!=null){%><div class="alert alert-success"><%=session.getAttribute("successMessage")%></div><%session.removeAttribute("successMessage");}%>
  <section class="material-grid">
  <%for(LearningMaterial m:materials){ String icon="VIDEO".equals(m.getMaterialType())?"▶":"PDF".equals(m.getMaterialType())?"▤":"▧";%>
    <article class="material-card"><div class="material-icon"><%=icon%></div><div class="material-type"><%=m.getMaterialType()%></div><h2><%=m.getTitle()%></h2><p><%=m.getDescription()==null?"Chưa có mô tả.":m.getDescription()%></p><div class="material-meta"><span><%=m.getDurationMinutes()%> phút</span><span><%=m.getScopeType()%></span></div><div class="material-actions"><a class="btn btn-primary" href="<%=request.getContextPath()%>/materials?action=view&id=<%=m.getMaterialId()%>">Xem trực tiếp</a><%if(manage){%><a class="btn" href="<%=request.getContextPath()%>/materials?action=edit&id=<%=m.getMaterialId()%>">Sửa</a><%}%></div></article>
  <%}%>
  </section>
  <section class="my-classes"><div class="section-heading"><div><span class="eyebrow">LỘ TRÌNH CỦA TÔI</span><h2>Lớp đào tạo</h2></div><a class="btn" href="<%=request.getContextPath()%>/materials?action=classList">Tất cả lớp</a></div><%if(classes.isEmpty()){%><p class="empty-state">Bạn chưa được ghi danh vào lớp nào.</p><%}else{%><div class="class-chip-list"><%for(TrainingClass c:classes){%><a class="class-chip" href="<%=request.getContextPath()%>/materials?action=classDetail&id=<%=c.getClassId()%>"><b><%=c.getClassName()%></b><span><%=c.getStatus()%></span></a><%}%></div><%}%></section>
</div></main><jsp:include page="/views/common/footer.jsp"/>
