<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="my_pack.Report" %>
<%@ page import="my_pack.Assessment" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String testId = request.getParameter("id");
    Report testDetails = null;
    List<Map<String, String>> questions = new ArrayList<>();
    
    try {
        Class.forName("org.postgresql.Driver");
        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/yourdb", "username", "password");
        
        // Get test details
        PreparedStatement stmt = conn.prepareStatement(
            "SELECT tr.id, tr.score, tr.status, tr.recommendation, " +
            "u.name AS user_name, a.name AS assessment_name, t.created_date " +
            "FROM test_results tr " +
            "JOIN users u ON tr.user_id = u.id " +
            "JOIN assessments a ON tr.assessment_id = a.id " +
            "JOIN tests t ON tr.test_id = t.id " +
            "WHERE tr.id = ?");
        stmt.setInt(1, Integer.parseInt(testId));
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            testDetails = new Report(
                rs.getInt("id"),
                rs.getString("user_name"),
                rs.getString("assessment_name"),
                rs.getDate("created_date"),
                rs.getDouble("score"),
                rs.getString("status"),
                rs.getString("recommendation")
            );
        }
        rs.close();
        stmt.close();
        
        // Get questions and answers
        stmt = conn.prepareStatement(
            "SELECT q.id, q.text, q.question_type, q.difficulty, " +
            "ua.submitted_answer, ua.is_correct " +
            "FROM questions q " +
            "JOIN user_answers ua ON q.id = ua.question_id " +
            "WHERE ua.test_id = ?");
        stmt.setInt(1, Integer.parseInt(testId));
        rs = stmt.executeQuery();
        
        while (rs.next()) {
            Map<String, String> question = new HashMap<>();
            question.put("id", rs.getString("id"));
            question.put("text", rs.getString("text"));
            question.put("type", rs.getString("question_type"));
            question.put("difficulty", rs.getString("difficulty"));
            question.put("answer", rs.getString("submitted_answer"));
            question.put("correct", rs.getBoolean("is_correct") ? "Correct" : "Incorrect");
            questions.add(question);
        }
        
        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Test Details</title>
    <style>
        /* Include the same CSS as in reports.jsp */
    </style>
</head>
<body>
    <div class="container">
        <div class="sidebar">
            <h2>Quizefy System</h2>
            <ul class="sidebar-menu">
                <li><a href="index.jsp">Dashboard</a></li>
                <li><a href="assessments.jsp">Manage Assessments</a></li>
                <li><a href="manageTests.jsp">Manage Tests</a></li>
                <li><a href="users.jsp">Manage Users</a></li>
                <li><a href="reports.jsp">Performance Reports</a></li>
                <li><a href="questions.jsp">Question Bank</a></li>
            </ul>
        </div>

        <div class="main-content">
            <header>
                <h1 class="page-title">Test Details</h1>
                <div class="user-info">
                    <span>Admin User</span>
                    <div class="user-avatar">AU</div>
                </div>
            </header>

            <div class="card">
                <% if (testDetails != null) { %>
                    <h3>Test Information</h3>
                    <div class="test-info">
                        <p><strong>Test ID:</strong> <%= testDetails.getId() %></p>
                        <p><strong>Date Taken:</strong> <%= testDetails.getDateTaken() %></p>
                        <p><strong>User:</strong> <%= testDetails.getUserName() %></p>
                        <p><strong>Assessment:</strong> <%= testDetails.getAssessmentName() %></p>
                        <p><strong>Score:</strong> <%= testDetails.getFormattedScore() %></p>
                        <p><strong>Status:</strong> 
                            <span class="status-<%= testDetails.isPassed() ? "active" : "inactive" %>">
                                <%= testDetails.getStatus() %>
                            </span>
                        </p>
                        <% if (testDetails.getRecommendation() != null && !testDetails.getRecommendation().isEmpty()) { %>
                            <p><strong>Recommendation:</strong> <%= testDetails.getRecommendation() %></p>
                        <% } %>
                    </div>

                    <div class="divider"></div>

                    <h3>Question Details</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>Question</th>
                                <th>Type</th>
                                <th>Difficulty</th>
                                <th>Answer</th>
                                <th>Result</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, String> question : questions) { %>
                                <tr>
                                    <td><%= question.get("text") %></td>
                                    <td><%= question.get("type") %></td>
                                    <td><%= question.get("difficulty") %></td>
                                    <td><%= question.get("answer") %></td>
                                    <td>
                                        <span class="status-<%= question.get("correct").equalsIgnoreCase("Correct") ? "active" : "inactive" %>">
                                            <%= question.get("correct") %>
                                        </span>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } else { %>
                    <div class="alert alert-danger">Test details not found</div>
                <% } %>

                <div class="divider"></div>

                <a href="reports.jsp" class="btn btn-primary">Back to Reports</a>
            </div>

            <div class="footer">
                <p>Support | Documentation</p>
                <p>© 2025 Assessment System</p>
            </div>
        </div>
    </div>
</body>
</html>