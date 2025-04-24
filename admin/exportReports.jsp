<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/csv;charset=UTF-8" %>

<%
    response.setHeader("Content-Disposition", "attachment; filename=performance_report.csv");
    
    String moduleFilter = request.getParameter("module") != null ? request.getParameter("module") : "all";
    String userFilter = request.getParameter("user") != null ? request.getParameter("user") : "all";
    String dateFilter = request.getParameter("date") != null ? request.getParameter("date") : "all";
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/yourdb", "username", "password");
        
        StringBuilder sql = new StringBuilder(
            "SELECT tr.score, tr.status, u.name AS user_name, " +
            "a.name AS assessment_name, t.created_date " +
            "FROM test_results tr " +
            "JOIN users u ON tr.user_id = u.id " +
            "JOIN assessments a ON tr.assessment_id = a.id " +
            "JOIN tests t ON tr.test_id = t.id " +
            "WHERE 1=1");
        
        List<String> params = new ArrayList<>();
        
        if (!moduleFilter.equals("all")) {
            sql.append(" AND a.id = ?");
            params.add(moduleFilter);
        }
        
        if (!userFilter.equals("all")) {
            sql.append(" AND u.id = ?");
            params.add(userFilter);
        }
        
        if (!dateFilter.equals("all")) {
            LocalDate now = LocalDate.now();
            if (dateFilter.equals("month")) {
                sql.append(" AND t.created_date >= ?");
                params.add(now.minusMonths(1).toString());
            } else if (dateFilter.equals("week")) {
                sql.append(" AND t.created_date >= ?");
                params.add(now.minusWeeks(1).toString());
            }
        }
        
        stmt = conn.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            stmt.setString(i + 1, params.get(i));
        }
        
        rs = stmt.executeQuery();
        
        // CSV header
        out.println("User,Assessment,Date Taken,Score,Status");
        
        // CSV data
        while (rs.next()) {
            out.print("\"" + rs.getString("user_name") + "\",");
            out.print("\"" + rs.getString("assessment_name") + "\",");
            out.print("\"" + rs.getDate("created_date") + "\",");
            out.print("\"" + String.format("%.0f%%", rs.getDouble("score") * 100) + "\",");
            out.println("\"" + rs.getString("status") + "\"");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>