<%@ page import="my_pack.DBConnection, java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    int resultId = Integer.parseInt(request.getParameter("result_id"));
    Map<String, String> result = new HashMap<>();
    List<Map<String, String>> answers = new ArrayList<>();
    
    String resultSql = "SELECT r.score, r.status, a.name as assessment_name, " +
                      "(SELECT COUNT(*) FROM user_answers WHERE test_result_id = r.id AND is_correct = true) as correct_count, " +
                      "(SELECT COUNT(*) FROM user_answers WHERE test_result_id = r.id) as total_questions " +
                      "FROM test_results r " +
                      "JOIN assessments a ON r.assessment_id = a.id " +
                      "WHERE r.id = ?";
    
    String answersSql = "SELECT q.text, ua.submitted_answer, ua.is_correct, q.question_type " +
                       "FROM user_answers ua " +
                       "JOIN questions q ON ua.question_id = q.id " +
                       "WHERE ua.test_result_id = ? " +
                       "ORDER BY ua.id";
    
    try (Connection conn = DBConnection.getConnection()) {
        // Get test result
        try (PreparedStatement stmt = conn.prepareStatement(resultSql)) {
            stmt.setInt(1, resultId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                result.put("score", rs.getString("score"));
                result.put("status", rs.getString("status"));
                result.put("assessment_name", rs.getString("assessment_name"));
                result.put("correct_count", rs.getString("correct_count"));
                result.put("total_questions", rs.getString("total_questions"));
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
            --danger-color: #e74c3c;
        }
        
        body {
            background-color: var(--light-gray);
            color: var(--dark-gray);
            line-height: 1.6;
            padding: 0;
            margin: 0;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .result-header {
            background-color: var(--white);
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            text-align: center;
        }
        
        .result-title {
            color: var(--primary-color);
            margin-bottom: 10px;
        }
        
        .result-score {
            font-size: 2.5rem;
            font-weight: bold;
            margin: 20px 0;
            color: <%= "Pass".equals(result.get("status")) ? "var(--success-color)" : "var(--danger-color)" %>;
        }
        
        .result-status {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 20px;
        }
        
        .result-details {
            display: flex;
            justify-content: space-around;
            margin-top: 20px;
        }
        
        .detail-item {
            text-align: center;
        }
        
        .detail-label {
            font-size: 0.9rem;
            color: var(--dark-gray);
        }
        
        .detail-value {
            font-weight: 600;
            margin-top: 5px;
        }
        
        .answers-summary {
            background-color: var(--white);
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .answer-item {
            margin-bottom: 20px;
            padding: 15px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .answer-item.true {
            background-color: rgba(46, 204, 113, 0.1);
        }
        
        .answer-item.false {
            background-color: rgba(231, 76, 60, 0.1);
        }
        
        .question-text {
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .user-answer {
            margin-bottom: 5px;
        }
        
        .correctness {
            font-weight: 600;
        }
        
        .correctness.true {
            color: var(--success-color);
        }
        
        .correctness.false {
            color: var(--danger-color);
        }
        
        .back-btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: var(--primary-color);
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: 600;
        }
        
        .back-btn:hover {
            background-color: var(--secondary-color);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="result-header">
            <h1>Assessment Results</h1>
            <h2><%= result.get("assessment_name") %></h2>
            
            <div class="result-score">
                <%= String.format("%.0f", Double.parseDouble(result.get("score"))) %>%
            </div>
            <div class="result-status">
                <%= result.get("status") %>
            </div>
        </div>
        
        <div class="answers-summary">
            <h3>Question Review</h3>
            
            <% for (int i = 0; i < answers.size(); i++) { 
                Map<String, String> answer = answers.get(i);
                boolean isCorrect = Boolean.parseBoolean(answer.get("is_correct"));
            %>
                <div class="answer-item <%= isCorrect ? "true" : "false" %>">
                    <div class="question-text">Q<%= i+1 %>. <%= answer.get("text") %></div>
                    <div class="user-answer">Your answer: <%= answer.get("answer") %></div>
                    <div class="correctness <%= isCorrect ? "true" : "false" %>">
                        <%= isCorrect ? "✓ Correct" : "✗ Incorrect" %>
                    </div>
                </div>
            <% } %>
        </div>
        
        <a href="homepage.jsp" class="back-btn">Back to Home</a>
    </div>
</body>
</html>