<%@ page import="my_pack.DBConnection, java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    int assessmentId = Integer.parseInt(request.getParameter("assessment_id"));
    int userId = Integer.parseInt(request.getParameter("user_id"));
    
    // Calculate score
    int totalQuestions = 0;
    int correctAnswers = 0;
    List<Map<String, String>> answers = new ArrayList<>();
    
    Enumeration<String> paramNames = request.getParameterNames();
    while (paramNames.hasMoreElements()) {
        String paramName = paramNames.nextElement();
        if (paramName.startsWith("q_")) {
            totalQuestions++;
            String questionId = paramName.substring(2);
            String answer = request.getParameter(paramName);
            
            // In a real app, verify answer against correct_answer in database
            boolean isCorrect = Math.random() > 0.5; // Random for demo
            
            if (isCorrect) correctAnswers++;
            
            Map<String, String> answerData = new HashMap<>();
            answerData.put("question_id", questionId);
            answerData.put("answer", answer);
            answerData.put("is_correct", String.valueOf(isCorrect));
            answers.add(answerData);
        }
    }
    
    double score = totalQuestions > 0 ? (correctAnswers * 100.0) / totalQuestions : 0;
    String status = score >= 50 ? "Pass" : "Fail";
    
    // Save test result
    String resultSql = "INSERT INTO test_results " +
                      "(user_id, assessment_id, score, status) " +
                      "VALUES (?, ?, ?, ?) RETURNING id";
    
    int testResultId = 0;
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(resultSql)) {
        
        stmt.setInt(1, userId);
        stmt.setInt(2, assessmentId);
        stmt.setDouble(3, score);
        stmt.setString(4, status);
        
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            testResultId = rs.getInt(1);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    // Save individual answers
    if (testResultId > 0) {
        String answerSql = "INSERT INTO user_answers " +
                         "(user_id, question_id, test_id, submitted_answer, is_correct) " +
                         "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(answerSql)) {
            
            for (Map<String, String> answer : answers) {
                stmt.setInt(1, userId);
                stmt.setInt(2, Integer.parseInt(answer.get("question_id")));
                stmt.setInt(3, testResultId);
                stmt.setString(4, answer.get("answer"));
                stmt.setBoolean(5, Boolean.parseBoolean(answer.get("is_correct")));
                stmt.addBatch();
            }
            
            stmt.executeBatch();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    response.sendRedirect("testResult.jsp?result_id=" + testResultId);
%>