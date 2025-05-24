<%@ page import="my_pack.DBConnection, my_pack.AssessmentManager, java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% 
    // Check if user is logged in
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=session_expired");
        return;
    }

    // Validate assessment_id parameter
    int assessmentId;
    try {
        assessmentId = Integer.parseInt(request.getParameter("assessment_id"));
    } catch (NumberFormatException e) {
        response.sendRedirect(request.getContextPath() + "/error.jsp?message=Invalid assessment ID");
        return;
    }

    Connection conn = null;
    int testResultId = 0;
    
    try {
        // Initialize database connection
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false); // Start transaction

        // Process submitted answers
        int totalQuestions = 0;
        int correctAnswers = 0;
        List<Map<String, String>> answers = new ArrayList<>();
        AssessmentManager assessmentManager = new AssessmentManager();

        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            if (paramName.startsWith("q_")) {
                totalQuestions++;
                String questionIdStr = paramName.substring(2);
                
                try {
                    int questionId = Integer.parseInt(questionIdStr);
                    String submittedAnswer = request.getParameter(paramName);
                    
                    // Validate answer against database
                    boolean isCorrect = assessmentManager.checkAnswer(questionId, submittedAnswer);
                    
                    if (isCorrect) correctAnswers++;
                    
                    Map<String, String> answerData = new HashMap<>();
                    answerData.put("question_id", questionIdStr);
                    answerData.put("answer", submittedAnswer);
                    answerData.put("is_correct", String.valueOf(isCorrect));
                    answers.add(answerData);
                } catch (NumberFormatException e) {
                    System.err.println("Invalid question ID format: " + questionIdStr);
                }
            }
        }
        
        // Calculate score
        double score = totalQuestions > 0 ? (correctAnswers * 100.0) / totalQuestions : 0;
        String status = score >= 50 ? "Pass" : "Fail";
        
        // Save test result
        String resultSql = "INSERT INTO test_results " +
                         "(user_id, assessment_id, score, status, created_date) " +
                         "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP) RETURNING id";
        
        try (PreparedStatement stmt = conn.prepareStatement(resultSql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, assessmentId);
            stmt.setDouble(3, score);
            stmt.setString(4, status);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                testResultId = rs.getInt(1);
            }
        }

        // Save individual answers if test result was saved successfully
        if (testResultId > 0) {
            String answerSql = "INSERT INTO user_answers " +
                             "(user_id, question_id, test_id, submitted_answer, is_correct) " +
                             "VALUES (?, ?, ?, ?, ?)";
            
            try (PreparedStatement stmt = conn.prepareStatement(answerSql)) {
                for (Map<String, String> answer : answers) {
                    try {
                        stmt.setInt(1, userId);
                        stmt.setInt(2, Integer.parseInt(answer.get("question_id")));
                        stmt.setInt(3, testResultId);
                        stmt.setString(4, answer.get("answer"));
                        stmt.setBoolean(5, Boolean.parseBoolean(answer.get("is_correct")));
                        stmt.addBatch();
                    } catch (NumberFormatException e) {
                        System.err.println("Invalid question ID in answers: " + answer.get("question_id"));
                    }
                }
                stmt.executeBatch();
            }
        }
        
        conn.commit(); // Commit transaction if everything succeeds
        
    } catch (SQLException e) {
        // Rollback transaction if any error occurs
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                System.err.println("Error during rollback: " + ex.getMessage());
            }
        }
        e.printStackTrace();
        response.sendRedirect(request.getContextPath() + "/error.jsp?message=Database error: " + e.getMessage());
        return;
    } finally {
        // Clean up resources
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }
    
    // Redirect to results page if everything succeeded
    response.sendRedirect(request.getContextPath() + "/testResult.jsp?result_id=" + testResultId);
%>