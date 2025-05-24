<%@ page import="java.sql.*" %>
<%
    int userCount = 0;
    int recruiterCount = 0;
    int assessmentCount = 0;
    String[] recentAssessments = new String[5];  // Store names of recent assessments
    String[] recentAssessmentDates = new String[5];  // Store dates of recent assessments

    String[] recentTestsTitles = new String[5];  // Store activities descriptions
    String[] recentTestsassessmentid = new String[5]; 
    String[] recentTeststargetDifficulty = new String[5]; 
    String[] recentTestsDates = new String[5];  // Store activity dates

    try {
        // Establish the database connection
        Class.forName("org.postgresql.Driver");
     Connection conn = DriverManager.getConnection(
    "jdbc:postgresql://turntable.proxy.rlwy.net:13001/railway",
    "postgres",
    "XpPVJptmTjhLhoaJwkDokjThDkkYuJPV"
);


        Statement stmt = conn.createStatement();

        // Total users
        ResultSet rsUsers = stmt.executeQuery("SELECT COUNT(*) FROM users");
        if (rsUsers.next()) {
            userCount = rsUsers.getInt(1);
        }
        rsUsers.close();

        // Recruiters
        ResultSet rsRecruiters = stmt.executeQuery("SELECT COUNT(*) FROM users WHERE role = 'recruiter'");
        if (rsRecruiters.next()) {
            recruiterCount = rsRecruiters.getInt(1);
        }
        rsRecruiters.close();

        // Assessments
        ResultSet rsAssessments = stmt.executeQuery("SELECT COUNT(*) FROM assessments");
        if (rsAssessments.next()) {
            assessmentCount = rsAssessments.getInt(1);
        }
        rsAssessments.close();

        // Recent Assessments
        ResultSet rsRecentAssessments = stmt.executeQuery("SELECT name, description FROM assessments   LIMIT 5");
        int index = 0;
        while (rsRecentAssessments.next() && index < 5) {
            recentAssessments[index] = rsRecentAssessments.getString("name");
            recentAssessmentDates[index] = rsRecentAssessments.getString("description");
            index++;
        }
        rsRecentAssessments.close();

        // Query for recent tests
        ResultSet rsRecentTests = stmt.executeQuery("SELECT title, assessment_id, created_date, target_difficulty FROM tests ORDER BY created_date DESC LIMIT 5");
        int activityIndex = 0;
        while (rsRecentTests.next() && activityIndex < 5) {
            recentTestsTitles[activityIndex] = rsRecentTests.getString("title");
            recentTestsassessmentid[activityIndex] = rsRecentTests.getString("assessment_id");
            recentTestsDates[activityIndex] = rsRecentTests.getString("created_date");
            recentTeststargetDifficulty[activityIndex] = rsRecentTests.getString("target_difficulty");
            activityIndex++;
        }
        rsRecentTests.close();

        // Close the connection
        stmt.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>


<!DOCTYPE html>
<html lang="en">
<head>
    
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assessment System - Dashboard</title>
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

        <!-- Main Content Area -->
        <div class="main-content">
            <header>
                <h1 class="page-title">Dashboard</h1>
                <div class="user-info">
                    <span>Admin User</span>
                    <div class="user-avatar">AU</div>
                </div>
            </header>

            <!-- System Overview Cards -->
            <div class="system-overview">
                <div class="stat-card">
                    <div class="number"><%= userCount %></div>
                    <div class="label">Total Users</div>

                </div>
                <div class="stat-card">
                    <div class="number"><%= assessmentCount %></div>
                    <div class="label">Assessments Created</div>
                </div>
                <div class="stat-card">
                    <div class="number"><%= recruiterCount %></div>
                    <div class="label">Recruiters Registered</div>
                </div>
            </div>

  
            <!-- Recent Assessments Table -->
            <div class="card">
                <h3>Recent Assessments</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Assessment Name</th>
                            <th>Description</th>
                        </tr>
                    </thead>
                      <tbody>
                        <% for (int i = 0; i < recentAssessments.length; i++) { %>
                            <% if (recentAssessments[i] != null) { %>
                                <tr>
                                    <td><%= recentAssessments[i] %></td>
                                    <td><%= recentAssessmentDates[i] %></td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div class="divider"></div>

            <!-- Recent Activities Table -->
            <div class="card">
                <h3>Recent Tests</h3>
                <table>
                    <thead>
                        <tr>
                            <th>title</th>
                            <th>assessment_id</th>

                            <th>created at</th>
                            <th>target_difficulty</th>
                        </tr>
                    </thead>
                                 <tbody>
                        <% for (int i = 0; i < recentTestsTitles.length; i++) { %>
                            <% if (recentTestsTitles[i] != null) { %>
                                <tr>
                                    <td><%= recentTestsTitles[i] %></td>
                                    <td><%= recentTestsassessmentid[i] %></td>
                                    <td><%= recentTestsDates[i] %></td>
                                    <td><%= recentTeststargetDifficulty[i] %></td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div class="footer">
                <p>Support | Documentation</p>
                <p>© 2025 Quizify System</p>
            </div>
        </div>
    </div>
</body>
</html>