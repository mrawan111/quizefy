<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Initialize variables
    int userId = 0;
    int testId = 0;
    int assessmentId = 0;
    int totalQuestions = 0;
    double totalScore = 0.0;
    String errorMessage = null;
    int testResultId = 0;

    // Get parameters from request
    try {
        userId = Integer.parseInt(request.getParameter("user_id"));
        testId = Integer.parseInt(request.getParameter("testId"));
        assessmentId = Integer.parseInt(request.getParameter("assessment_id"));
    } catch (NumberFormatException e) {
        errorMessage = "Invalid user ID, test ID, or assessment ID format.";
    }

    Connection conn = null;
    try {
        if (errorMessage == null) {
            // Database connection setup
            String dbUrl = System.getenv("DB_URL") != null ? System.getenv("DB_URL") : 
                "jdbc:postgresql://turntable.proxy.rlwy.net:13001/railway";
            String dbUser = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "postgres";
            String dbPass = System.getenv("DB_PASS") != null ? System.getenv("DB_PASS") : "XpPVJptmTjhLhoaJwkDokjThDkkYuJPV";

            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            conn.setAutoCommit(false);

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
                    } else {
                        throw new SQLException("Failed to create test result record.");
                    }
                }
            }

            // 2. Fetch all questions (MCQ and text)
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
                        totalQuestions++;
                    }
                }
            }

            // 3. Evaluate answers
            for (int questionId : questionIds) {
                String questionType = questionTypes.get(questionId);
                boolean isCorrect = false;
                String submittedAnswer = null;

                if ("MCQ".equals(questionType)) {
                    // Handle MCQ questions
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
                                }
                            }
                        }
                    }
                } else {
                    // Handle text questions
                    submittedAnswer = request.getParameter("q_" + questionId);
                    // For text questions, you might want to add manual grading logic here
                    // Currently marking as incorrect by default
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

                // Add score if correct
                if (isCorrect) {
                    totalScore += questionWeights.getOrDefault(questionId, 0.0);
                }
            }

            // 4. Update test_result with final score and recommendation
            double percentage = (totalQuestions > 0) ? (totalScore / totalQuestions) * 100 : 0;
            String recommendation = (percentage >= 50) ? "Pass" : "Fail";
            String status = "Completed";
            
            String updateResultSQL = "UPDATE test_results SET score = ?, status = ?, recommendation = ? WHERE id = ?";
            try (PreparedStatement updatePs = conn.prepareStatement(updateResultSQL)) {
                updatePs.setDouble(1, totalScore);
                updatePs.setString(2, status);
                updatePs.setString(3, recommendation);
                updatePs.setInt(4, testResultId);
                updatePs.executeUpdate();
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
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f7fa;
            padding: 0;
            margin: 0;
            color: #333;
        }
        .container {
            background: white;
            max-width: 800px;
            margin: 40px auto;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            text-align: center;
        }
        h2 {
            margin-top: 0;
            font-size: 28px;
        }
        .success { color: #27ae60; }
        .error { color: #e74c3c; }
        .result-card {
            padding: 30px;
            border-radius: 10px;
            margin: 30px 0;
            background-color: #f8f9fa;
            border: 1px solid #e0e0e0;
        }
        .pass {
            background-color: #e8f8f0;
            border-left: 6px solid #27ae60;
        }
        .fail {
            background-color: #fdecea;
            border-left: 6px solid #e74c3c;
        }
        .score-display {
            font-size: 36px;
            font-weight: bold;
            margin: 20px 0;
            color: #2c3e50;
        }
        .percentage {
            font-size: 28px;
            margin: 15px 0;
            font-weight: 600;
        }
        .status {
            font-size: 24px;
            font-weight: bold;
            margin: 20px auto;
            padding: 12px 24px;
            border-radius: 6px;
            display: inline-block;
            width: fit-content;
        }
        .status-pass {
            background-color: #27ae60;
            color: white;
        }
        .status-fail {
            background-color: #e74c3c;
            color: white;
        }
        .message {
            font-size: 18px;
            margin: 15px 0;
            line-height: 1.6;
        }
        .btn {
            display: inline-block;
            padding: 12px 28px;
            background-color: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            margin-top: 25px;
            transition: all 0.3s ease;
            font-size: 16px;
            font-weight: 600;
            border: none;
            cursor: pointer;
        }
        .btn:hover {
            background-color: #2980b9;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .details {
            margin-top: 30px;
            text-align: left;
            border-top: 1px solid #eee;
            padding-top: 20px;
        }
        .detail-item {
            margin-bottom: 10px;
            display: flex;
            justify-content: space-between;
        }
        .detail-label {
            font-weight: 600;
            color: #7f8c8d;
        }
        .detail-value {
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="container">
        <% if (errorMessage != null) { %>
            <h2 class="error">Submission Error</h2>
            <p><%= errorMessage %></p>
            <a href="javascript:history.back()" class="btn">Go Back</a>
        <% } else { 
            double percentage = (totalQuestions > 0) ? (totalScore / totalQuestions) * 100 : 0;
            boolean passed = percentage >= 50;
        %>
            <h2 class="success">Test Submitted Successfully!</h2>
            
            <div class="result-card <%= passed ? "pass" : "fail" %>">
                <div class="score-display">
                    <%= (int)totalScore %> / <%= totalQuestions %>
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
                    <span class="detail-label">Test ID:</span>
                    <span class="detail-value"><%= testId %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Result ID:</span>
                    <span class="detail-value"><%= testResultId %></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Date:</span>
                    <span class="detail-value"><%= new java.util.Date() %></span>
                </div>
            </div>
            
            <a href="results.jsp?result_id=<%= testResultId %>" class="btn">View Detailed Results</a>
        <% } %>
    </div>
</body>
</html>