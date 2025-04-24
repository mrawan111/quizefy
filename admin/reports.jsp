<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.format.*" %>
<%@ page import="java.time.format.*" %>
<%@ page import="my_pack.Report" %>


<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Database connection and data retrieval
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    // Initialize variables for filters
    String moduleFilter = request.getParameter("module") != null ? request.getParameter("module") : "all";
    String userFilter = request.getParameter("user") != null ? request.getParameter("user") : "all";
    String dateFilter = request.getParameter("date") != null ? request.getParameter("date") : "all";
    
    // Data structures for results
    List<Map<String, String>> testResults = new ArrayList<>();
    List<Map<String, String>> modules = new ArrayList<>();
    List<Map<String, String>> users = new ArrayList<>();
    
    // Performance metrics
    double averageScore = 0;
    double highestScore = 0;
    String highestScoreUser = "";
    String highestScoreModule = "";
    double completionRate = 0;
    int totalTests = 0;
    int completedTests = 0;
    
    try {
        // Get database connection
       Class.forName("org.postgresql.Driver");
         conn = DriverManager.getConnection(
            "jdbc:postgresql://crossover.proxy.rlwy.net:29928/railway", "postgres", "TzRGIYmjwyLwlaZPPGoziHjOakANiumm"
        );
        // Get all assessments (modules)
        stmt = conn.prepareStatement("SELECT id, name FROM assessments");
        rs = stmt.executeQuery();
        while (rs.next()) {
            Map<String, String> module = new HashMap<>();
            module.put("id", rs.getString("id"));
            module.put("name", rs.getString("name"));
            modules.add(module);
        }
        rs.close();
        stmt.close();
        
        // Get all users
        stmt = conn.prepareStatement("SELECT id, name FROM users WHERE role = 'candidate'");
        rs = stmt.executeQuery();
        while (rs.next()) {
            Map<String, String> user = new HashMap<>();
            user.put("id", rs.getString("id"));
            user.put("name", rs.getString("name"));
            users.add(user);
        }
        rs.close();
        stmt.close();
        
        // Build SQL query based on filters
        StringBuilder sql = new StringBuilder(
            "SELECT tr.score, tr.status, tr.test_id, u.name AS user_name, " +
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
            } else if (dateFilter.equals("custom")) {
                // You would need to add custom date range handling
            }
        }
        
        sql.append(" ORDER BY t.created_date DESC");
        
        stmt = conn.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            stmt.setString(i + 1, params.get(i));
        }
        
        rs = stmt.executeQuery();
        while (rs.next()) {
            Map<String, String> result = new HashMap<>();
            result.put("user", rs.getString("user_name"));
            result.put("assessment", rs.getString("assessment_name"));
            result.put("date", rs.getDate("created_date").toString());
            result.put("score", String.format("%.0f%%", rs.getDouble("score") * 100));
            result.put("status", rs.getString("status"));
            result.put("test_id", rs.getString("test_id"));
            testResults.add(result);
            
            // Calculate metrics
            double score = rs.getDouble("score") * 100;
            averageScore += score;
            totalTests++;
            
            if (score > highestScore) {
                highestScore = score;
                highestScoreUser = rs.getString("user_name");
                highestScoreModule = rs.getString("assessment_name");
            }
            
            if (rs.getString("status").equals("Pass") || rs.getString("status").equals("Fail")) {
                completedTests++;
            }
        }
        
        // Calculate final metrics
        if (totalTests > 0) {
            averageScore = averageScore / totalTests;
            completionRate = ((double) completedTests / totalTests) * 100;
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Assessment System - Performance Reports</title>
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
            font-size: 24px;
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
            color: var(--dark-gray);
        }
        
        .card {
            background-color: var(--white);
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
        
        .report-filters {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .filter-group {
            flex: 1;
            min-width: 200px;
        }
        
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid var(--medium-gray);
            border-radius: 5px;
            font-size: 16px;
            background-color: var(--white);
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--dark-gray);
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            transition: background-color 0.3s ease;
            margin-right: 10px;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            color: var(--white);
        }
        
        .btn-primary:hover {
            background-color: var(--secondary-color);
        }
        
        .btn-sm {
            padding: 5px 10px;
            font-size: 14px;
        }
        
        .divider {
            height: 1px;
            background-color: var(--medium-gray);
            margin: 20px 0;
        }
        
        .chart-container {
            background-color: var(--white);
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            height: 400px;
        }
        
        .chart-placeholder {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            background-color: var(--light-gray);
            border-radius: 4px;
            color: var(--dark-gray);
            font-style: italic;
        }
        
        .score-distribution {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .score-card {
            background-color: var(--white);
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        
        .score-card h4 {
            margin-bottom: 10px;
            color: var(--primary-color);
            font-size: 18px;
        }
        
        .score-value {
            font-size: 24px;
            font-weight: bold;
            margin: 10px 0;
            color: var(--dark-gray);
        }
        
        .improvement-tag {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 12px;
            margin-left: 5px;
            font-weight: 600;
        }
        
        .improvement-up {
            background-color: #d4edda;
            color: #155724;
        }
        
        .improvement-down {
            background-color: #f8d7da;
            color: #721c24;
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
            color: var(--dark-gray);
        }
        
        table tr:hover {
            background-color: var(--light-gray);
        }
        
        .status-active {
            color: var(--success-color);
            font-weight: 500;
        }
        
        .status-inactive {
            color: var(--danger-color);
            font-weight: 500;
        }
        
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid var(--medium-gray);
            text-align: center;
            color: var(--dark-gray);
            font-size: 14px;
        }
        
        .footer p {
            margin-bottom: 5px;
        }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .container {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
                padding: 15px;
            }
            
            .main-content {
                padding: 20px;
            }
            
            .report-filters {
                flex-direction: column;
                gap: 10px;
            }
            
            .filter-group {
                width: 100%;
            }
        }
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
                <li><a href="reports.jsp" class="active">Performance Reports</a></li>
                <li><a href="questions.jsp">Question Bank</a></li>
            </ul>
        </div>

        <div class="main-content">
            <header>
                <h1 class="page-title">Performance Reports</h1>
                <div class="user-info">
                    <span>Admin User</span>
                    <div class="user-avatar">AU</div>
                </div>
            </header>

            <div class="card">
                <form method="get">
                    <div class="report-filters">
                        <div class="filter-group">
                            <label for="reportModule">Module</label>
                            <select id="reportModule" name="module" class="form-control">
                                <option value="all">All Modules</option>
                                <% for (Map<String, String> module : modules) { %>
                                    <option value="<%= module.get("id") %>" <%= module.get("id").equals(moduleFilter) ? "selected" : "" %>>
                                        <%= module.get("name") %>
                                    </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label for="reportUser">User</label>
                            <select id="reportUser" name="user" class="form-control">
                                <option value="all">All Users</option>
                                <% for (Map<String, String> user : users) { %>
                                    <option value="<%= user.get("id") %>" <%= user.get("id").equals(userFilter) ? "selected" : "" %>>
                                        <%= user.get("name") %>
                                    </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label for="reportDate">Date Range</label>
                            <select id="reportDate" name="date" class="form-control">
                                <option value="all" <%= dateFilter.equals("all") ? "selected" : "" %>>All Time</option>
                                <option value="month" <%= dateFilter.equals("month") ? "selected" : "" %>>Last Month</option>
                                <option value="week" <%= dateFilter.equals("week") ? "selected" : "" %>>Last Week</option>
                                <option value="custom" <%= dateFilter.equals("custom") ? "selected" : "" %>>Custom Range</option>
                            </select>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary">Generate Report</button>
                    <button type="button" class="btn" onclick="exportToCSV()">Export to CSV</button>

                    <div class="divider"></div>

                    <h3>Performance Overview</h3>
                    <div class="chart-container">
                        <div class="chart-placeholder">
                            Performance Chart Visualization Would Appear Here
                            <!-- In a real application, you would integrate a charting library here -->
                        </div>
                    </div>

                    <div class="score-distribution">
                        <div class="score-card">
                            <h4>Average Score</h4>
                            <div class="score-value"><%= String.format("%.0f%%", averageScore) %> 
                                <span class="improvement-tag improvement-up">+5%</span>
                            </div>
                            <p>Across all assessments and users</p>
                        </div>
                        <div class="score-card">
                            <h4>Highest Score</h4>
                            <div class="score-value"><%= String.format("%.0f%%", highestScore) %></div>
                            <p>Achieved by <%= highestScoreUser %> in <%= highestScoreModule %></p>
                        </div>
                        <div class="score-card">
                            <h4>Completion Rate</h4>
                            <div class="score-value"><%= String.format("%.0f%%", completionRate) %> 
                                <span class="improvement-tag improvement-down">-2%</span>
                            </div>
                            <p>Percentage of started assessments that were completed</p>
                        </div>
                    </div>

                    <div class="divider"></div>

                    <h3>Detailed Results</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>User</th>
                                <th>Assessment</th>
                                <th>Date Taken</th>
                                <th>Score</th>
                                <th>Status</th>
                                <th>Details</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, String> result : testResults) { %>
                                <tr>
                                    <td><%= result.get("user") %></td>
                                    <td><%= result.get("assessment") %></td>
                                    <td><%= result.get("date") %></td>
                                    <td><%= result.get("score") %></td>
                                    <td>
                                        <span class="status-<%= result.get("status").equalsIgnoreCase("Pass") ? "active" : "inactive" %>">
                                            <%= result.get("status") %>
                                        </span>
                                    </td>
                                    <td>
                                        <a href="testDetails.jsp?id=<%= result.get("test_id") %>" class="btn btn-sm btn-primary">View</a>
                                    </td>
                                </tr>
                            <% } %>
                            <% if (testResults.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" style="text-align: center;">No results found for the selected filters</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </form>
            </div>

            <div class="footer">
                <p>Support | Documentation</p>
                <p>© 2025 Assessment System</p>
            </div>
        </div>
    </div>
    
    <script>
        function exportToCSV() {
            // In a real application, this would generate and download a CSV file
            alert("CSV export functionality would be implemented here");
            
            // Example of how this might work:
            // window.location.href = 'exportReports.jsp?module=<%= moduleFilter %>&user=<%= userFilter %>&date=<%= dateFilter %>';
        }
    </script>
</body>
</html>