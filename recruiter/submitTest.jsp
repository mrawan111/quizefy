<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    int userId = 0;
    int testId = 0;
    int totalQuestions = 0;
    double totalScore = 0.0;
    String errorMessage = null;
    int testResultId = 0;

    try {
        userId = Integer.parseInt(request.getParameter("user_id"));
        testId = Integer.parseInt(request.getParameter("testId"));
    } catch (NumberFormatException e) {
        errorMessage = "Invalid user ID or test ID format.";
    }

    Connection conn = null;
    try {
        if (errorMessage == null) {
            String dbUrl = System.getenv("DB_URL") != null ? System.getenv("DB_URL") : 
                "jdbc:postgresql://turntable.proxy.rlwy.net:13001/railway";
            String dbUser = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "postgres";
            String dbPass = System.getenv("DB_PASS") != null ? System.getenv("DB_PASS") : "XpPVJptmTjhLhoaJwkDokjThDkkYuJPV";

            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            conn.setAutoCommit(false);

            // 1. Insert into test_results
            String insertResultSQL = "INSERT INTO test_results (user_id, test_id, assessment_id, score, status, recommendation) " +
                                     "VALUES (?, ?, (SELECT assessment_id FROM tests WHERE id = ?), 0, 'Pending', '') RETURNING id";
            try (PreparedStatement insertPs = conn.prepareStatement(insertResultSQL)) {
                insertPs.setInt(1, userId);
                insertPs.setInt(2, testId);
                insertPs.setInt(3, testId);
                try (ResultSet rs = insertPs.executeQuery()) {
                    if (rs.next()) {
                        testResultId = rs.getInt(1);
                    } else {
                        throw new SQLException("Failed to create test result record.");
                    }
                }
            }

            // 2. Fetch MCQ questions
            String fetchQuestionsSQL = "SELECT id, weight FROM questions WHERE test_id = ? AND question_type = 'MCQ'";
            List<Integer> questionIds = new ArrayList<>();
            Map<Integer, Double> questionWeights = new HashMap<>();

            try (PreparedStatement fetchPs = conn.prepareStatement(fetchQuestionsSQL)) {
                fetchPs.setInt(1, testId);
                try (ResultSet rs = fetchPs.executeQuery()) {
                    while (rs.next()) {
                        int questionId = rs.getInt("id");
                        double weight = rs.getDouble("weight");
                        questionIds.add(questionId);
                        questionWeights.put(questionId, weight);
                        totalQuestions++;
                    }
                }
            }

            // 3. Evaluate answers
            for (int questionId : questionIds) {
                String selectedOptionIdStr = request.getParameter("question_" + questionId);
                Integer selectedOptionId = (selectedOptionIdStr != null && !selectedOptionIdStr.isEmpty())
                    ? Integer.parseInt(selectedOptionIdStr) : null;

                boolean isCorrect = false;
                if (selectedOptionId != null) {
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

                // Insert into answers table
                String insertAnswerSQL = "INSERT INTO user_answers (test_result_id, question_id, submitted_answer, is_correct) VALUES (?, ?, ?, ?)";
                try (PreparedStatement answerPs = conn.prepareStatement(insertAnswerSQL)) {
                    answerPs.setInt(1, testResultId);
                    answerPs.setInt(2, questionId);
                    if (selectedOptionId != null) {
                        answerPs.setInt(3, selectedOptionId);
                    } else {
                        answerPs.setNull(3, java.sql.Types.INTEGER);
                    }
                    answerPs.setBoolean(4, isCorrect);
                    answerPs.executeUpdate();
                }

                // Add score if correct
                if (isCorrect) {
                    totalScore += questionWeights.getOrDefault(questionId, 0.0);
                }
            }

            // 4. Update test_result
            String recommendation = (totalScore >= 50) ? "Pass" : "Fail";
            String updateResultSQL = "UPDATE test_results SET score = ?, status = 'Completed', recommendation = ? WHERE id = ?";
            try (PreparedStatement updatePs = conn.prepareStatement(updateResultSQL)) {
                updatePs.setDouble(1, totalScore);
                updatePs.setString(2, recommendation);
                updatePs.setInt(3, testResultId);
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
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            padding: 20px;
        }
        .container {
            background: white;
            max-width: 800px;
            margin: auto;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <div class="container">
        <% if (errorMessage != null) { %>
            <h2 class="error">Submission Error</h2>
            <p><%= errorMessage %></p>
            <a href="javascript:history.back()">Go Back</a>
        <% } else { %>
            <h2 class="success">Test Submitted Successfully!</h2>
            <p><strong>Score:</strong> <%= totalScore %></p>
            <p><strong>Percentage:</strong> 
                <%= totalQuestions > 0 ? String.format("%.2f", (totalScore / totalQuestions) * 100) : "0" %>%</p>
            <a href="results.jsp?result_id=<%= testResultId %>">View Detailed Results</a>
        <% } %>
    </div>

</body>
</html>
