<%@ page import="my_pack.ReportService" %>
<%@ page import="my_pack.ChartData" %>
<%@ page import="my_pack.TestResult" %>
<%@ page import="my_pack.Assessment" %>
<%@ page import="my_pack.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    int assessmentId = request.getParameter("assessment_id") != null ? 
                      Integer.parseInt(request.getParameter("assessment_id")) : 0;
    int userId = request.getParameter("user_id") != null ? 
                Integer.parseInt(request.getParameter("user_id")) : 0;
    String dateRange = request.getParameter("date_range");
    
    List<TestResult> results = ReportService.getFilteredResults(assessmentId, userId, dateRange);
    ChartData chartData = ReportService.getChartData(assessmentId, userId, dateRange);
    List<Assessment> assessments = ReportService.getAllAssessments();
    List<User> users = ReportService.getAllUsers();
    List<Map<String, Object>> trendData = ReportService.getPerformanceTrend(assessmentId, userId, "week");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Performance Reports</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
        
        .card {
            background-color: var(--white);
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
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
        
        .divider {
            height: 1px;
            background-color: var(--medium-gray);
            margin: 20px 0;
        }
        
        .chart-container {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin: 20px 0;
        }
        
        .chart-box {
            flex: 1;
            min-width: 300px;
            padding: 15px;
            background: var(--white);
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .score-high {
            color: var(--success-color);
            font-weight: 500;
        }
        
        .score-medium {
            color: var(--warning-color);
            font-weight: 500;
        }
        
        .score-low {
            color: var(--danger-color);
            font-weight: 500;
        }
        
        .status-active {
            color: var(--success-color);
        }
        
        .status-inactive {
            color: var(--danger-color);
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
                <li><a href="users.jsp">Manage Users</a></li>
                <li><a href="reports.jsp">Performance Reports</a></li>
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
                <form method="get" action="reports.jsp">
                    <div class="form-group">
                        <label for="reportModule">Assessment:</label>
                        <select id="reportModule" name="assessment_id" class="form-control">
                            <option value="0">All Assessments</option>
                            <% for (Assessment assessment : assessments) { %>
                                <option value="<%= assessment.getId() %>" 
                                    <%= assessment.getId() == assessmentId ? "selected" : "" %>>
                                    <%= assessment.getName() %>
                                </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="reportUser">User:</label>
                        <select id="reportUser" name="user_id" class="form-control">
                            <option value="0">All Users</option>
                            <% for (User user : users) { %>
                                <option value="<%= user.getId() %>" 
                                    <%= user.getId() == userId ? "selected" : "" %>>
                                    <%= user.getName() %>
                                </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="reportDate">Date Range:</label>
                        <select id="reportDate" name="date_range" class="form-control">
                            <option value="">All Time</option>
                            <option value="week" <%= "week".equals(dateRange) ? "selected" : "" %>>Last Week</option>
                            <option value="month" <%= "month".equals(dateRange) ? "selected" : "" %>>Last Month</option>
                        </select>
                    </div>

                </form>

                <div class="divider"></div>

                <h3>Performance Overview</h3>
                <div class="chart-container">
                    <div class="chart-box">
                        <canvas id="scoreDistributionChart"></canvas>
                    </div>
                    <div class="chart-box">
                        <canvas id="performanceTrendChart"></canvas>
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
                        <% if (results.isEmpty()) { %>
                            <tr>
                                <td colspan="6" style="text-align: center;">No results found for the selected criteria.</td>
                            </tr>
                        <% } else { 
                            for (TestResult result : results) { 
                                String scoreClass = "";
                                if (result.getScore() >= 80) scoreClass = "score-high";
                                else if (result.getScore() >= 50) scoreClass = "score-medium";
                                else scoreClass = "score-low";
                        %>
                        <tr>
                            <td><%= result.getUserName() != null ? result.getUserName() : "N/A" %></td>
                            <td><%= result.getAssessmentName() != null ? result.getAssessmentName() : "N/A" %></td>
                            <td><%= result.getCreatedDate() != null ? new java.text.SimpleDateFormat("MM/dd/yyyy").format(result.getCreatedDate()) : "N/A" %></td>
                            <td class="<%= scoreClass %>">
                                <%= String.format("%.0f%%", result.getScore()) %>
                            </td>
                            <td>
                                <span class="<%= "Pass".equals(result.getstatues()) ? "status-active" : "status-inactive" %>">
                                    <%= result.getstatues() != null ? result.getstatues() : "N/A" %>
                                </span>
                            </td>
                            <td>
                                <button class="btn btn-primary" onclick="viewDetails(<%= result.getId() %>)">View</button>
                            </td>
                        </tr>
                        <% } 
                        } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        // Score Distribution Chart
        const scoreCtx = document.getElementById('scoreDistributionChart');
        new Chart(scoreCtx, {
            type: 'doughnut',
            data: {
                labels: ['High (≥80%)', 'Medium (50-79%)', 'Low (<50%)'],
                datasets: [{
                    data: [
                        <%= chartData.getHighScore() %>, 
                        <%= chartData.getMediumScore() %>, 
                        <%= chartData.getLowScore() %>
                    ],
                    backgroundColor: [
                        '#2ecc71', // green
                        '#f39c12', // orange
                        '#e74c3c'  // red
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom'
                    },
                    title: {
                        display: true,
                        text: 'Score Distribution',
                        font: {
                            size: 16
                        }
                    }
                }
            }
        });

        // Performance Trend Chart
        const trendCtx = document.getElementById('performanceTrendChart');
        new Chart(trendCtx, {
            type: 'line',
            data: {
                labels: [<%= getTrendLabels(trendData) %>],
                datasets: [{
                    label: 'Average Score',
                    data: [<%= getTrendValues(trendData) %>],
                    borderColor: '#3498db',
                    backgroundColor: 'rgba(52, 152, 219, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    },
                    title: {
                        display: true,
                        text: 'Performance Trend',
                        font: {
                            size: 16
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: false,
                        min: 0,
                        max: 100,
                        ticks: {
                            callback: function(value) {
                                return value + '%';
                            }
                        }
                    }
                }
            }
        });

        function viewDetails(resultId) {
            window.location.href = 'testResultDetails.jsp?id=' + resultId;
        }
        
      
    </script>
</body>
</html>

<%!
    private String getTrendLabels(List<Map<String, Object>> trendData) {
        StringBuilder labels = new StringBuilder();
        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd");
        for (Map<String, Object> data : trendData) {
            if (labels.length() > 0) labels.append(", ");
            labels.append("'").append(sdf.format(data.get("week"))).append("'");
        }
        return labels.toString();
    }

    private String getTrendValues(List<Map<String, Object>> trendData) {
        StringBuilder values = new StringBuilder();
        for (Map<String, Object> data : trendData) {
            if (values.length() > 0) values.append(", ");
            values.append(data.get("avg_score"));
        }
        return values.toString();
    }
%>