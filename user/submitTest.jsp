<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Initialize variables
    int userId = 0;
    int assessmentId = 0;
    String[] testIds = null;
    double totalScore = 0.0;
    double totalPossibleScore = 0.0;
    String errorMessage = null;
    List<Integer> testResultIds = new ArrayList<>();

    // Get parameters from request
    try {
        userId = Integer.parseInt(request.getParameter("user_id"));
        assessmentId = Integer.parseInt(request.getParameter("assessment_id"));
        String testIdsParam = request.getParameter("testIds");
        if (testIdsParam != null && !testIdsParam.isEmpty()) {
            testIds = testIdsParam.split(",");
        } else {
            errorMessage = "Test IDs are missing";
        }
    } catch (NumberFormatException e) {
        errorMessage = "Invalid user ID or assessment ID format: " + e.getMessage();
    }

    Connection conn = null;
    try {
        if (errorMessage == null && testIds != null) {
            // Database connection setup
            String dbUrl = System.getenv("DB_URL") != null ? System.getenv("DB_URL") : 
                "jdbc:postgresql://turntable.proxy.rlwy.net:13001/railway";
            String dbUser = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "postgres";
            String dbPass = System.getenv("DB_PASS") != null ? System.getenv("DB_PASS") : "XpPVJptmTjhLhoaJwkDokjThDkkYuJPV";

            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            conn.setAutoCommit(false);

            // Process each test
            for (String testIdStr : testIds) {
                int testId = Integer.parseInt(testIdStr);
                int testResultId = 0;
                double testScore = 0.0;
                double testPossibleScore = 0.0;

                // 1. Insert into test_results
                String insertResultSQL = "INSERT INTO test_results (user_id, test_id, assessment_id, score, status, recommendation) " +
                                       "VALUES (?, ?, ?, 0, 'Pending', '') RETURNING id";
                try (PreparedStatement insertPs = conn.prepareStatement(insertResultSQL)) {
                    insertPs.setInt(1, userId);
                    insertPs.setInt(2, testId);
                    insertPs.setInt(3, assessmentId);
                    try (ResultSet rs = insertPs.executeQuery()) {
                        if (rs.next()) {
                            testResultId = rs.getInt(1);
                            testResultIds.add(testResultId);
                        } else {
                            throw new SQLException("Failed to create test result record.");
                        }
                    }
                }

                // 2. Fetch all questions for this test
                String fetchQuestionsSQL = "SELECT id, weight, question_type FROM questions WHERE test_id = ?";
                List<Integer> questionIds = new ArrayList<>();
                Map<Integer, Double> questionWeights = new HashMap<>();
                Map<Integer, String> questionTypes = new HashMap<>();

                try (PreparedStatement fetchPs = conn.prepareStatement(fetchQuestionsSQL)) {
                    fetchPs.setInt(1, testId);
                    try (ResultSet rs = fetchPs.executeQuery()) {
                        while (rs.next()) {
                            int questionId = rs.getInt("id");
                            double weight = rs.getDouble("weight");
                            String questionType = rs.getString("question_type");
                            questionIds.add(questionId);
                            questionWeights.put(questionId, weight);
                            questionTypes.put(questionId, questionType);
                            testPossibleScore += weight;
                            totalPossibleScore += weight;
                        }
                    }
                }

                // 3. Evaluate answers for this test
                for (int questionId : questionIds) {
                    String questionType = questionTypes.get(questionId);
                    boolean isCorrect = false;
                    String submittedAnswer = null;

                    if ("MCQ".equals(questionType)) {
                        // Handle MCQ questions with weighted scoring
                        String selectedOptionIdStr = request.getParameter("q_" + questionId);
                        Integer selectedOptionId = (selectedOptionIdStr != null && !selectedOptionIdStr.isEmpty())
                            ? Integer.parseInt(selectedOptionIdStr) : null;

                        if (selectedOptionId != null) {
                            submittedAnswer = selectedOptionId.toString();
                            String checkAnswerSQL = "SELECT is_correct FROM question_options WHERE id = ? AND question_id = ?";
                            try (PreparedStatement checkPs = conn.prepareStatement(checkAnswerSQL)) {
                                checkPs.setInt(1, selectedOptionId);
                                checkPs.setInt(2, questionId);
                                try (ResultSet rs = checkPs.executeQuery()) {
                                    if (rs.next()) {
                                        isCorrect = rs.getBoolean("is_correct");
                                        if (isCorrect) {
                                            double weight = questionWeights.get(questionId);
                                            testScore += weight;
                                            totalScore += weight;
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // Handle text questions (default to 0 score)
                        submittedAnswer = request.getParameter("q_" + questionId);
                        isCorrect = false;
                    }

                    // Insert into answers table
                    String insertAnswerSQL = "INSERT INTO user_answers (test_result_id, question_id, submitted_answer, is_correct) VALUES (?, ?, ?, ?)";
                    try (PreparedStatement answerPs = conn.prepareStatement(insertAnswerSQL)) {
                        answerPs.setInt(1, testResultId);
                        answerPs.setInt(2, questionId);
                        if (submittedAnswer != null && !submittedAnswer.isEmpty()) {
                            answerPs.setString(3, submittedAnswer);
                        } else {
                            answerPs.setNull(3, java.sql.Types.VARCHAR);
                        }
                        answerPs.setBoolean(4, isCorrect);
                        answerPs.executeUpdate();
                    }
                }

                // 4. Update test_result with final weighted score and recommendation
                double testPercentage = (testPossibleScore > 0) ? (testScore / testPossibleScore) * 100 : 0;
                String testRecommendation = (testPercentage >= 50) ? "Pass" : "Fail";
                String status = "Completed";
                
                String updateResultSQL = "UPDATE test_results SET score = ?, status = ?, recommendation = ? WHERE id = ?";
                try (PreparedStatement updatePs = conn.prepareStatement(updateResultSQL)) {
                    updatePs.setDouble(1, testPercentage);  // Store actual weighted score
                    updatePs.setString(2, status);
                    updatePs.setString(3, testRecommendation);
                    updatePs.setInt(4, testResultId);
                    updatePs.executeUpdate();
                }
            }

            conn.commit();
        }
    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
        errorMessage = "An error occurred: " + e.getMessage();
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Test Submission Result</title>
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
        
        .result-card {
            padding: 25px;
            border-radius: 8px;
            margin-bottom: 30px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            border-left: 4px solid;
        }
        
        .result-card.pass {
            border-left-color: var(--success-color);
            background-color: rgba(46, 204, 113, 0.05);
        }
        
        .result-card.fail {
            border-left-color: var(--danger-color);
            background-color: rgba(231, 76, 60, 0.05);
        }
        
        .score-display {
            font-size: 36px;
            font-weight: bold;
            text-align: center;
            margin: 20px 0;
        }
        
        .pass .score-display {
            color: var(--success-color);
        }
        
        .fail .score-display {
            color: var(--danger-color);
        }
        
        .percentage {
            font-size: 24px;
            font-weight: 600;
            text-align: center;
            margin: 15px 0;
        }
        
        .status {
            font-size: 20px;
            font-weight: bold;
            text-align: center;
            margin: 20px 0;
            padding: 10px;
            border-radius: 6px;
            display: inline-block;
            width: 100%;
        }
        
        .status-pass {
            background-color: var(--success-color);
            color: white;
        }
        
        .status-fail {
            background-color: var(--danger-color);
            color: white;
        }
        
        .message {
            font-size: 16px;
            text-align: center;
            margin: 20px 0;
            line-height: 1.6;
        }
        
        .details {
            margin-top: 30px;
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
        }
        
        .detail-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .detail-item:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }
        
        .detail-label {
            font-weight: 600;
            color: #666;
        }
        
        .detail-value {
            font-weight: 500;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 24px;
            background-color: var(--primary-color);
            color: white;
            text-decoration: none;
            border-radius: 6px;
            margin-top: 20px;
            font-size: 16px;
            font-weight: 500;
            border: none;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
            width: 100%;
        }
        
        .btn:hover {
            background-color: var(--secondary-color);
        }
        
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid var(--danger-color);
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 20px;
            }
            
            .score-display {
                font-size: 28px;
            }
            
            .percentage {
                font-size: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <% if (errorMessage != null) { %>
            <div class="error-message">
                <h2>Submission Error</h2>
                <p><%= errorMessage %></p>
                <a href="javascript:history.back()" class="btn">Go Back</a>
            </div>
        <% } else { 
            double percentage = (totalPossibleScore > 0) ? (totalScore / totalPossibleScore) * 100 : 0;
            boolean passed = percentage >= 50;
        %>
            <div class="result-header">
                <h1 class="result-title">Assessment Submitted</h1>
            </div>
            
            <div class="result-card <%= passed ? "pass" : "fail" %>">
                <div class="score-display">
                    <%= String.format("%.1f", totalScore) %> / <%= String.format("%.1f", totalPossibleScore) %>
                </div>
                <div class="percentage">
                    <%= String.format("%.1f", percentage) %>%
                </div>
                <div class="status <%= passed ? "status-pass" : "status-fail" %>">
                    <%= passed ? "PASSED" : "FAILED" %>
                </div>
                
                <div class="message">
                    <% if (passed) { %>
                        <p>Congratulations! You have successfully passed the assessment.</p>
                    <% } else { %>
                        <p>You didn't meet the passing score. Keep practicing and try again!</p>
                    <% } %>
                </div>
            </div>
            
            <div class="details">
                <div class="detail-item">
                    <span class="detail-label">Assessment ID:</span>
                    <span class="detail-value"><%= assessmentId %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Tests Completed:</span>
                    <span class="detail-value"><%= testIds != null ? testIds.length : 0 %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Result IDs:</span>
                    <span class="detail-value"><%= String.join(", ", testResultIds.stream().map(String::valueOf).toArray(String[]::new)) %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Date:</span>
                    <span class="detail-value"><%= new java.util.Date() %></span>
                </div>
            </div>
            
            <a href="testResultDetails.jsp?result_id=<%= !testResultIds.isEmpty() ? testResultIds.get(0) : 0 %>" class="btn">View Detailed Results</a>
        <% } %>
    </div>
</body>
</html>