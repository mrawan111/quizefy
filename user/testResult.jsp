<%@ page import="my_pack.DBConnection, java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    int resultId = Integer.parseInt(request.getParameter("result_id"));
    Map<String, String> result = new HashMap<>();
    List<Map<String, String>> answers = new ArrayList<>();
    
    String resultSql = "SELECT r.score, r.status, r.recommendation, a.name as assessment_name " +
                      "FROM test_results r " +
                      "JOIN assessments a ON r.assessment_id = a.id " +
                      "WHERE r.id = ?";
    
    String answersSql = "SELECT q.text, ua.submitted_answer, ua.is_correct, q.question_type " +
                       "FROM user_answers ua " +
                       "JOIN questions q ON ua.question_id = q.id " +
                       "WHERE ua.test_result_id = ?";
    
    try (Connection conn = DBConnection.getConnection()) {
        // Get test result
        try (PreparedStatement stmt = conn.prepareStatement(resultSql)) {
            stmt.setInt(1, resultId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                result.put("score", rs.getString("score"));
                result.put("status", rs.getString("status"));
                result.put("recommendation", rs.getString("recommendation"));
                result.put("assessment_name", rs.getString("assessment_name"));
            }
        }
        
        // Get answers
        try (PreparedStatement stmt = conn.prepareStatement(answersSql)) {
            stmt.setInt(1, resultId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, String> answer = new HashMap<>();
                answer.put("text", rs.getString("text"));
                answer.put("answer", rs.getString("submitted_answer"));
                answer.put("is_correct", rs.getString("is_correct"));
                answer.put("type", rs.getString("question_type"));
                answers.add(answer);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Test Results - <%= result.get("assessment_name") %></title>
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
            max-width: 800px;
            margin: 0 auto;
            background-color: var(--white);
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 30px;
        }
        
        .result-header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .result-title {
            color: var(--primary-color);
            margin-bottom: 10px;
            font-size: 24px;
        }
        
        .result-score {
            font-size: 36px;
            font-weight: bold;
            text-align: center;
            margin: 20px 0;
            color: <%= "Pass".equals(result.get("status")) ? "var(--success-color)" : "var(--danger-color)" %>;
        }
        
        .result-status {
            font-size: 20px;
            font-weight: 600;
            text-align: center;
            margin-bottom: 20px;
            padding: 10px;
            border-radius: 6px;
            background-color: <%= "Pass".equals(result.get("status")) ? "var(--success-color)" : "var(--danger-color)" %>;
            color: white;
        }
        
        .result-details {
            display: flex;
            justify-content: space-around;
            margin-top: 20px;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .detail-item {
            text-align: center;
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            flex: 1;
            min-width: 120px;
        }
        
        .detail-label {
            font-size: 14px;
            color: #666;
            margin-bottom: 5px;
        }
        
        .detail-value {
            font-weight: 600;
        }
        
        .answers-summary {
            margin-top: 30px;
        }
        
        .answers-title {
            color: var(--primary-color);
            margin-bottom: 20px;
            font-size: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .answer-item {
            margin-bottom: 20px;
            padding: 20px;
            border-radius: 8px;
            background-color: var(--white);
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border-left: 4px solid;
        }
        
        .answer-item.true {
            border-left-color: var(--success-color);
            background-color: rgba(46, 204, 113, 0.05);
        }
        
        .answer-item.false {
            border-left-color: var(--danger-color);
            background-color: rgba(231, 76, 60, 0.05);
        }
        
        .question-text {
            font-weight: 600;
            margin-bottom: 10px;
            font-size: 16px;
        }
        
        .user-answer {
            margin-bottom: 10px;
            padding: 10px;
            background-color: #f8f9fa;
            border-radius: 4px;
            font-size: 14px;
        }
        
        .correctness {
            font-weight: 600;
            display: inline-block;
            padding: 5px 10px;
            border-radius: 4px;
        }
        
        .correctness.true {
            color: var(--success-color);
            background-color: rgba(46, 204, 113, 0.1);
        }
        
        .correctness.false {
            color: var(--danger-color);
            background-color: rgba(231, 76, 60, 0.1);
        }
        
        .btn {
            display: inline-block;
            padding: 12px 24px;
            background-color: var(--primary-color);
            color: white;
            text-decoration: none;
            border-radius: 6px;
            margin-top: 30px;
            font-size: 16px;
            font-weight: 500;
            transition: all 0.3s;
            text-align: center;
            width: 100%;
        }
        
        .btn:hover {
            background-color: var(--secondary-color);
        }
        
        .recommendation {
            margin-top: 20px;
            padding: 15px;
            border-radius: 6px;
            background-color: #f8f9fa;
            font-style: italic;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 20px;
            }
            
            .result-score {
                font-size: 28px;
            }
            
            .result-status {
                font-size: 18px;
            }
            
            .detail-item {
                min-width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="result-header">
            <h1 class="result-title">Assessment Results</h1>
            <h2><%= result.get("assessment_name") %></h2>
            
            <div class="result-score">
                <%= String.format("%.0f", Double.parseDouble(result.get("score"))) %>%
            </div>
            <div class="result-status">
                <%= result.get("status") %>
            </div>
        </div>
        
        <div class="result-details">
            <div class="detail-item">
                <div class="detail-label">Result ID</div>
                <div class="detail-value"><%= resultId %></div>
            </div>
            <div class="detail-item">
                <div class="detail-label">Date</div>
                <div class="detail-value"><%= new java.util.Date() %></div>
            </div>
        </div>
        
        <% if (result.get("recommendation") != null && !result.get("recommendation").isEmpty()) { %>
            <div class="recommendation">
                <strong>Recommendation:</strong> <%= result.get("recommendation") %>
            </div>
        <% } %>
        
        <div class="answers-summary">
            <h3 class="answers-title">Question Review</h3>
            
            <% for (int i = 0; i < answers.size(); i++) { 
                Map<String, String> answer = answers.get(i);
                boolean isCorrect = Boolean.parseBoolean(answer.get("is_correct"));
            %>
                <div class="answer-item <%= isCorrect ? "true" : "false" %>">
                    <div class="question-text">Q<%= i+1 %>. <%= answer.get("text") %></div>
                    <div class="user-answer">
                        <strong>Your answer:</strong> 
                        <% if (answer.get("answer") != null) { %>
                            <%= "MCQ".equals(answer.get("type")) ? "Option " + answer.get("answer") : answer.get("answer") %>
                        <% } else { %>
                            Not answered
                        <% } %>
                    </div>
                    <div class="correctness <%= isCorrect ? "true" : "false" %>">
                        <%= isCorrect ? "✓ Correct" : "✗ Incorrect" %>
                    </div>
                </div>
            <% } %>
        </div>
        
        <a href="homepage.jsp" class="btn">Back to Home</a>
    </div>
</body>
</html>