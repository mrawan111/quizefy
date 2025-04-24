<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="my_pack.Assessment" %>
<%@ page import="my_pack.Test" %>
<%@ page import="my_pack.DBConnection" %>
<%@ page import="java.time.LocalDate" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    List<Assessment> assessments = new ArrayList<>();
    List<Test> tests = new ArrayList<>();
    String error = null;
    String successMessage = null;

    // Handle form submission (Create or Edit Test)
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String title = request.getParameter("title");
        String assessmentId = request.getParameter("assessment_id");
        String targetDifficulty = request.getParameter("target_difficulty");
        String testId = request.getParameter("test_id");

        try {
            conn = DBConnection.getConnection();

            String query = (testId != null && !testId.isEmpty()) ?
                "UPDATE tests SET title = ?, assessment_id = ?, target_difficulty = ?, created_date = ? WHERE id = ?" :
                "INSERT INTO tests (title, assessment_id, created_date, target_difficulty) VALUES (?, ?, ?, ?)";

            stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);

            // Always use current date
            java.sql.Date createdDate = java.sql.Date.valueOf(LocalDate.now());

            // Set parameters
            stmt.setString(1, title);
            stmt.setInt(2, Integer.parseInt(assessmentId));

            if (testId != null && !testId.isEmpty()) {
                stmt.setInt(3, Integer.parseInt(targetDifficulty));
                stmt.setDate(4, createdDate);
                stmt.setInt(5, Integer.parseInt(testId));
            } else {
                stmt.setDate(3, createdDate);
                stmt.setInt(4, Integer.parseInt(targetDifficulty));
            }

            int rows = stmt.executeUpdate();
            
            if (rows > 0) {
                if (testId == null || testId.isEmpty()) {
                    // Get the generated test ID for new tests
                    ResultSet generatedKeys = stmt.getGeneratedKeys();
                    if (generatedKeys.next()) {
                        testId = String.valueOf(generatedKeys.getInt(1));
                    }
                }
                
                // Redirect to questions page with the test ID
                response.sendRedirect("questions.jsp?test_id=" + testId);
                return;
            } else {
                error = "Failed to process test.";
            }
        } catch (Exception e) {
            error = "Error processing test: " + e.getMessage();
        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    // Delete test functionality
    String deleteId = request.getParameter("delete_id");
    if (deleteId != null) {
        try {
            conn = DBConnection.getConnection();
            stmt = conn.prepareStatement("DELETE FROM tests WHERE id = ?");
            stmt.setInt(1, Integer.parseInt(deleteId));
            stmt.executeUpdate();
            conn.close();
        } catch (Exception e) {
            error = "Error deleting test: " + e.getMessage();
        }
    }

    // Load assessments
    try {
        conn = DBConnection.getConnection();
        stmt = conn.prepareStatement("SELECT * FROM assessments");
        rs = stmt.executeQuery();
        while (rs.next()) {
            assessments.add(new Assessment(rs.getInt("id"), rs.getString("name")));
        }
    } catch (Exception e) {
        error = "Failed to load assessments: " + e.getMessage();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }

    // Load tests for listing
    try {
        conn = DBConnection.getConnection();
        stmt = conn.prepareStatement("SELECT t.id, t.title, t.target_difficulty, t.created_date, a.name as assessment_name FROM tests t JOIN assessments a ON t.assessment_id = a.id");
        rs = stmt.executeQuery();
        while (rs.next()) {
            Test test = new Test();
            test.setId(rs.getInt("id"));
            test.setTitle(rs.getString("title"));
            test.setAssessmentName(rs.getString("assessment_name"));
            test.setTargetDifficulty(rs.getInt("target_difficulty"));
            test.setCreatedDate(rs.getDate("created_date"));
            tests.add(test);
        }
    } catch (Exception e) {
        error = "Error loading tests: " + e.getMessage();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }

    // Load test details for edit if there's an 'id' parameter
    Test testToEdit = null;
    String testIdToEdit = request.getParameter("id");
    if (testIdToEdit != null && !testIdToEdit.isEmpty()) {
        try {
            conn = DBConnection.getConnection();
            stmt = conn.prepareStatement("SELECT * FROM tests WHERE id = ?");
            stmt.setInt(1, Integer.parseInt(testIdToEdit));
            rs = stmt.executeQuery();
            if (rs.next()) {
                testToEdit = new Test();
                testToEdit.setId(rs.getInt("id"));
                testToEdit.setTitle(rs.getString("title"));
                testToEdit.setAssessmentId(rs.getInt("assessment_id"));
                testToEdit.setTargetDifficulty(rs.getInt("target_difficulty"));
            }
        } catch (Exception e) {
            error = "Error loading test details for editing: " + e.getMessage();
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Tests - Quizify</title>
    <style>
        :root {
            --primary-color: #3498db;
            --secondary-color: #2980b9;
            --light-gray: #f5f5f5;
            --medium-gray: #e0e0e0;
            --dark-gray: #333;
            --white: #ffffff;
            --success-color: #2ecc71;
            --warning-color: #f39c12;
            --danger-color: #e74c3c;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background-color: var(--light-gray);
            color: var(--dark-gray);
            line-height: 1.6;
        }
        
        .container {
            display: flex;
            min-height: 100vh;
        }
        
        .sidebar {
            width: 250px;
            background-color: var(--white);
            padding: 20px;
            box-shadow: 2px 0 5px rgba(0, 0, 0, 0.1);
        }
        
        .sidebar h2 {
            color: var(--primary-color);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .sidebar-menu {
            list-style: none;
        }
        
        .sidebar-menu li {
            margin-bottom: 10px;
        }
        
        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 10px;
            color: var(--dark-gray);
            text-decoration: none;
            border-radius: 5px;
            transition: all 0.3s ease;
        }
        
        .sidebar-menu a:hover {
            background-color: var(--light-gray);
            color: var(--primary-color);
        }
        
        .sidebar-menu a.active {
            background-color: var(--primary-color);
            color: var(--white);
        }
        
        .main-content {
            flex: 1;
            padding: 30px;
        }
        
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        
        .page-title {
            color: var(--primary-color);
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: var(--medium-gray);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }
        
        .card-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .card {
            background-color: var(--white);
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        
        .card h3 {
            margin-bottom: 15px;
            color: var(--primary-color);
        }
        
        .system-overview {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background-color: var(--white);
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        
        .stat-card .number {
            font-size: 36px;
            font-weight: bold;
            color: var(--primary-color);
            margin: 10px 0;
        }
        
        .stat-card .label {
            color: var(--dark-gray);
            font-size: 14px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid var(--medium-gray);
            border-radius: 5px;
            font-size: 16px;
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            transition: background-color 0.3s ease;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            color: var(--white);
        }
        
        .btn-primary:hover {
            background-color: var(--secondary-color);
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        
        table th, table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        table th {
            background-color: var(--light-gray);
            font-weight: 600;
        }
        
        table tr:hover {
            background-color: var(--light-gray);
        }
        
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid var(--medium-gray);
            text-align: center;
            color: var(--dark-gray);
            font-size: 14px;
        }
        
        .divider {
            height: 1px;
            background-color: var(--medium-gray);
            margin: 20px 0;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="sidebar">
        <h2>Quizefy System</h2>
        <ul class="sidebar-menu">
            <li><a href="index.jsp" class="active">Dashboard</a></li>
            <li><a href="assessments.jsp">Manage Assessments</a></li>
            <li><a href="manageTests.jsp">Manage Tests</a></li>
            <li><a href="users.jsp">Manage Users</a></li>
            <li><a href="reports.jsp">Performance Reports</a></li>
            <li><a href="questions.jsp">Question Bank</a></li>
        </ul>
    </div>

    <div class="main-content">
        <header>
            <h1 class="page-title">Manage Tests</h1>
            <div class="user-info">
                <span>Admin User</span>
                <div class="user-avatar">AU</div>
            </div>
        </header>

        <% if (error != null) { %>
            <p style="color: red;"><%= error %></p>
        <% } %>

        <% if (successMessage != null) { %>
            <p style="color: green;"><%= successMessage %></p>
        <% } %>

        <div class="card">
            <h3><%= (testToEdit != null) ? "Edit Test" : "Create Test" %></h3>
            <form method="post">
                <% if (testToEdit != null) { %>
                    <input type="hidden" name="test_id" value="<%= testToEdit.getId() %>">
                <% } %>

                <div class="form-group">
                    <label for="testTitle">Test Title</label>
                    <input type="text" name="title" id="testTitle" class="form-control" value="<%= (testToEdit != null) ? testToEdit.getTitle() : "" %>" required>
                </div>

                <div class="form-group">
                    <label for="assessmentId">Assessment</label>
                    <select name="assessment_id" id="assessmentId" class="form-control" required>
                        <option value="">-- Select Assessment --</option>
                        <% for (Assessment a : assessments) { %>
                            <option value="<%= a.getId() %>" <%= (testToEdit != null && testToEdit.getAssessmentId() == a.getId()) ? "selected" : "" %>><%= a.getName() %></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="difficulty">Target Difficulty</label>
                    <input type="number" name="target_difficulty" id="difficulty" class="form-control" value="<%= (testToEdit != null) ? testToEdit.getTargetDifficulty() : "1" %>" required min="1" max="10">
                </div>

                <button class="btn btn-primary" type="submit">
                    <%= (testToEdit != null) ? "Update Test" : "Create Test" %>
                </button>
            </form>
        </div>

        <div class="divider"></div>

        <!-- Table displaying all tests -->
        <h3>All Tests</h3>
        <table>
            <thead>
                <tr>
                    <th>Test Title</th>
                    <th>Assessment</th>
                    <th>Target Difficulty</th>
                    <th>Created Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% for (Test test : tests) { %>
                    <tr>
                        <td><%= test.getTitle() %></td>
                        <td><%= test.getAssessmentName() %></td>
                        <td><%= test.getTargetDifficulty() > 0 ? test.getTargetDifficulty() : "Not set" %></td>
                        <td><%= test.getCreatedDate() != null ? test.getCreatedDate() : "Not set" %></td>
                        <td>
                            <a href="manageTests.jsp?id=<%= test.getId() %>" class="btn btn-primary">Edit</a>
                            <a href="manageTests.jsp?delete_id=<%= test.getId() %>" class="btn btn-danger">Delete</a>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>

    </div> <!-- End of main-content -->
</div> <!-- End of container -->

    <div class="footer">
        <p>Support | Documentation</p>
        <p>© 2025 Quizify System</p>
    </div>

<script>
    document.querySelector("form").addEventListener("submit", function(event) {
        const createdDateInput = document.querySelector("#createdDate");
        if (!createdDateInput.value) {
            createdDateInput.value = new Date().toISOString().split('T')[0];  // Sets the current date if empty
        }
    });
</script>
</body>
</html>