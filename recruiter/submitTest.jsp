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
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false); // Start transaction

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

        double score = totalQuestions > 0 ? (correctAnswers * 100.0) / totalQuestions : 0;
        String status = score >= 50 ? "Pass" : "Fail";

        String resultSql = "INSERT INTO test_results " +
                         "(user_id, assessment_id, score, status) " +
                         "VALUES (?, ?, ?, ?) RETURNING id";

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

        if (testResultId > 0) {
            String answerSql = "INSERT INTO user_answers " +
    "(user_id, question_id, test_result_id, submitted_answer, is_correct) " + 
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

        conn.commit(); // All successful

    } catch (SQLException e) {
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
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }

    // Redirect to test result page
    response.sendRedirect(request.getContextPath() + "/recruiter/testResult.jsp?result_id=" + testResultId);
%>
