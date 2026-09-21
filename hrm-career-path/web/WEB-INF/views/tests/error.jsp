<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="static utils.TestView.h" %>
<% request.setAttribute("pageTitle", "Bài test | HRM"); %>
<div id="testErrorMessage" hidden><%= h(request.getAttribute("testError")) %></div>
<script>window.alert(document.getElementById('testErrorMessage').textContent);if(window.history.length>1)window.history.back();else window.location.replace('<%= request.getContextPath() %>/tests');</script>
