<%@ page import="my_pack.ReportService" %>
<%@ page import="my_pack.TestResult" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
int resultId = Integer.parseInt(request.getParameter("result_id"));
    TestResult result = ReportService.getTestResultById(resultId);
    SimpleDateFormat dateFormat = new SimpleDateFormat("MM/dd/yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Test Result Details</title>
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
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: var(--white);
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            padding: 30px;
        }
        
        h1 {
            color: var(--primary-color);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .result-details {
            margin: 30px 0;
        }
        
        .detail-row {
            display: flex;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--light-gray);
        }
        
        .detail-label {
            font-weight: 600;
            width: 200px;
            color: var(--dark-gray);
        }
        
        .detail-value {
            flex: 1;
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            transition: background-color 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            color: var(--white);
        }
        
        .btn-primary:hover {
            background-color: var(--secondary-color);
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
        <h1>Test Result Details</h1>
        
        <div class="result-details">
            <div class="detail-row">
                <div class="detail-label">User Name:</div>
                <div class="detail-value"><%= result.getUserName() != null ? result.getUserName() : "N/A" %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Assessment Name:</div>
                <div class="detail-value"><%= result.getAssessmentName() != null ? result.getAssessmentName() : "N/A" %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Date Taken:</div>
                <div class="detail-value"><%= result.getCreatedDate() != null ? dateFormat.format(result.getCreatedDate()) : "N/A" %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Score:</div>
                <div class="detail-value <%= getScoreClass(result.getScore()) %>">
                    <%= String.format("%.0f%%", result.getScore()) %>
                </div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Status:</div>
                <div class="detail-value <%= "Pass".equals(result.getstatues()) ? "status-active" : "status-inactive" %>">
                    <%= result.getstatues() != null ? result.getstatues() : "N/A" %>
                </div>
            </div>
        </div>
        
        <a href="reports.jsp" class="btn btn-primary">Back to Reports</a>
    </div>
</body>
</html>

<%!
    private String getScoreClass(double score) {
        if (score >= 80) return "score-high";
        if (score >= 50) return "score-medium";
        return "score-low";
    }
%>