<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div style="text-align: center; margin-top: 40px;">
    <h2>Welcome to the Product Management System</h2>
    <p>This application demonstrates JSP and MySQL integration.</p>
    
    <div style="margin-top: 30px;">
        <a href="${pageContext.request.contextPath}/product-list.jsp" class="btn btn-primary">View Products</a>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
