<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Error</title>
</head>
<body>
    <h2>Error Occurred</h2>
    <p><%= request.getParameter("message") %></p>
    <a href="<%= request.getContextPath() %>/homepage.jsp">Return Home</a>
</body>
</html>