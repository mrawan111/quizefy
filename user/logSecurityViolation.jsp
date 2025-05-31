<%@ page import="my_pack.DBConnection, java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String violationType = request.getParameter("violation_type");
    int testId = Integer.parseInt(request.getParameter("test_id"));
    String sessionToken = request.getParameter("session_token");
    int userId = session.getAttribute("userId") != null ? (Integer) session.getAttribute("userId") : 0;
    
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "INSERT INTO security_logs (user_id, test_id, violation_type, session_token) VALUES (?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, testId);
            stmt.setString(3, violationType);
            stmt.setString(4, sessionToken);
            stmt.executeUpdate();
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    // Return empty response
    response.setContentType("text/plain");
    response.setCharacterEncoding("UTF-8");
%>