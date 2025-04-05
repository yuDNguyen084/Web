<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div style="text-align: center; margin: 40px 0;">
    <h2>Error</h2>
    
    <div class="error-message">
        <p><strong>Something went wrong!</strong></p>
        <% if (exception != null) { %>
            <p><%= exception.getMessage() %></p>
        <% } else { %>
            <p>An unexpected error occurred.</p>
        <% } %>
    </div>
    
    <p style="margin-top: 20px;">
        <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Return to Home</a>
    </p>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
