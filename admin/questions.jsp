<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="my_pack.Question" %>
<%@ page import="my_pack.Test" %>
<%@ page import="my_pack.DBConnection" %>
<%@ page import="java.util.Arrays" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    List<Question> questions = new ArrayList<>();
    List<Test> tests = new ArrayList<>();
    String error = null;
    String successMessage = null;
    String activeTab = request.getParameter("tab") != null ? request.getParameter("tab") : "all";
    String searchQuery = request.getParameter("search");
    String difficultyFilter = request.getParameter("difficulty");
    String testId = request.getParameter("test_id");

    // Load all tests for the test selector
    try {
        conn = DBConnection.getConnection();
        stmt = conn.prepareStatement("SELECT id, title FROM tests");
        rs = stmt.executeQuery();
        while (rs.next()) {
            Test test = new Test();
            test.setId(rs.getInt("id"));
            test.setTitle(rs.getString("title"));
            tests.add(test);
        }
    } catch (Exception e) {
        error = "Error loading tests: " + e.getMessage();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }

    // Handle form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String text = request.getParameter("text");
        String questionType = request.getParameter("question_type");
        String difficulty = request.getParameter("difficulty");
        String correctAnswer = request.getParameter("correct_answer");
        String weight = request.getParameter("weight");
        String questionId = request.getParameter("question_id");
        String testIdParam = request.getParameter("test_id");
        
        // For MCQ questions, format the options
        if ("MCQ".equals(questionType)) {
            String[] options = request.getParameterValues("options");
            String[] optionTexts = request.getParameterValues("option_text");
            StringBuilder optionsBuilder = new StringBuilder();
            
            for (int i = 0; i < options.length; i++) {
                optionsBuilder.append(options[i]).append(") ").append(optionTexts[i]);
                if (i < options.length - 1) {
                    optionsBuilder.append("|");
                }
            }
            correctAnswer = optionsBuilder.toString();
        }

        try {
            conn = DBConnection.getConnection();
            String query;
            
            if (questionId != null && !questionId.isEmpty()) {
                query = "UPDATE questions SET text=?, question_type=?, difficulty=?, correct_answer=?, weight=?, test_id=? WHERE id=?";
            } else {
                query = "INSERT INTO questions (text, question_type, difficulty, correct_answer, weight, test_id) VALUES (?, ?, ?, ?, ?, ?)";
            }
            
            stmt = conn.prepareStatement(query);
            stmt.setString(1, text);
            stmt.setString(2, questionType);
            stmt.setInt(3, Integer.parseInt(difficulty));
            stmt.setString(4, correctAnswer);
            stmt.setFloat(5, Float.parseFloat(weight));
            stmt.setInt(6, Integer.parseInt(testIdParam));
            
            if (questionId != null && !questionId.isEmpty()) {
                stmt.setInt(7, Integer.parseInt(questionId));
            }
            
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                successMessage = (questionId != null && !questionId.isEmpty()) ? 
                    "Question updated successfully!" : "Question created successfully!";
                // Redirect to show questions for the selected test
                response.sendRedirect("questions.jsp?test_id=" + testIdParam);
                return;
            }
        } catch (Exception e) {
            error = "Error processing question: " + e.getMessage();
        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    // Delete question functionality
    String deleteId = request.getParameter("delete_id");
    if (deleteId != null) {
        try {
            conn = DBConnection.getConnection();
            stmt = conn.prepareStatement("DELETE FROM questions WHERE id = ?");
            stmt.setInt(1, Integer.parseInt(deleteId));
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                successMessage = "Question deleted successfully!";
            }
        } catch (Exception e) {
            error = "Error deleting question: " + e.getMessage();
        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    // Load questions with filters
    try {
        conn = DBConnection.getConnection();
        StringBuilder queryBuilder = new StringBuilder("SELECT q.*, t.title as test_title FROM questions q LEFT JOIN tests t ON q.test_id = t.id WHERE 1=1");
        
        if (!"all".equals(activeTab)) {
            queryBuilder.append(" AND q.question_type = ?");
        }
        if (searchQuery != null && !searchQuery.isEmpty()) {
            queryBuilder.append(" AND q.text LIKE ?");
        }
        if (difficultyFilter != null && !"all".equals(difficultyFilter)) {
            queryBuilder.append(" AND q.difficulty = ?");
        }
        if (testId != null && !testId.isEmpty()) {
            queryBuilder.append(" AND q.test_id = ?");
        }
        
        stmt = conn.prepareStatement(queryBuilder.toString());
        
        int paramIndex = 1;
        if (!"all".equals(activeTab)) {
            stmt.setString(paramIndex++, activeTab);
        }
        if (searchQuery != null && !searchQuery.isEmpty()) {
            stmt.setString(paramIndex++, "%" + searchQuery + "%");
        }
        if (difficultyFilter != null && !"all".equals(difficultyFilter)) {
            stmt.setInt(paramIndex++, Integer.parseInt(difficultyFilter));
        }
        if (testId != null && !testId.isEmpty()) {
            stmt.setInt(paramIndex++, Integer.parseInt(testId));
        }
        
        rs = stmt.executeQuery();
        while (rs.next()) {
            Question question = new Question();
            question.setId(rs.getInt("id"));
            question.setText(rs.getString("text"));
            question.setQuestionType(rs.getString("question_type"));
            question.setDifficulty(rs.getInt("difficulty"));
            question.setCorrectAnswer(rs.getString("correct_answer"));
            question.setWeight(rs.getFloat("weight"));
           try {
    java.lang.reflect.Method setTestId = question.getClass().getMethod("setTestId", int.class);
    setTestId.invoke(question, rs.getInt("test_id"));
    
    java.lang.reflect.Method setTestTitle = question.getClass().getMethod("setTestTitle", String.class);
    setTestTitle.invoke(question, rs.getString("test_title"));
} catch (Exception e) {
    // Methods don't exist, skip them
}
            questions.add(question);
        }
    } catch (Exception e) {
        error = "Error loading questions: " + e.getMessage();
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }

    // Load question for edit
    Question questionToEdit = null;
    String questionIdToEdit = request.getParameter("edit_id");
    if (questionIdToEdit != null && !questionIdToEdit.isEmpty()) {
        try {
            conn = DBConnection.getConnection();
            stmt = conn.prepareStatement("SELECT * FROM questions WHERE id = ?");
            stmt.setInt(1, Integer.parseInt(questionIdToEdit));
            rs = stmt.executeQuery();
            if (rs.next()) {
                questionToEdit = new Question();
                questionToEdit.setId(rs.getInt("id"));
                questionToEdit.setText(rs.getString("text"));
                questionToEdit.setQuestionType(rs.getString("question_type"));
                questionToEdit.setDifficulty(rs.getInt("difficulty"));
                questionToEdit.setCorrectAnswer(rs.getString("correct_answer"));
                questionToEdit.setWeight(rs.getFloat("weight"));
try {
    java.lang.reflect.Method setTestId = questionToEdit.getClass().getMethod("setTestId", int.class);
    setTestId.invoke(questionToEdit, rs.getInt("test_id"));
} catch (Exception e) {
    // Method doesn't exist, skip it
}            }
        } catch (Exception e) {
            error = "Error loading question for editing: " + e.getMessage();
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Assessment System - Question Bank</title>
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
            font-size: 24px;
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
            color: var(--dark-gray);
        }
        
        .card {
            background-color: var(--white);
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
        
        .tab-container {
            margin-bottom: 20px;
        }
        
        .tabs {
            display: flex;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .tab {
            padding: 10px 20px;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            color: var(--dark-gray);
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .tab:hover {
            color: var(--primary-color);
        }
        
        .tab.active {
            border-bottom-color: var(--primary-color);
            color: var(--primary-color);
            font-weight: 600;
        }
        
        .question-filters {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .filter-group {
            flex: 1;
            min-width: 200px;
        }
        
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid var(--medium-gray);
            border-radius: 5px;
            font-size: 16px;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--dark-gray);
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            transition: all 0.3s ease;
            margin-bottom: 20px;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            color: var(--white);
        }
        
        .btn-primary:hover {
            background-color: var(--secondary-color);
        }
        
        .btn-sm {
            padding: 5px 10px;
            font-size: 14px;
        }
        
        .btn-warning {
            background-color: var(--warning-color);
            color: var(--white);
        }
        
        .btn-warning:hover {
            background-color: #e67e22;
        }
        
        .btn-danger {
            background-color: var(--danger-color);
            color: var(--white);
        }
        
        .btn-danger:hover {
            background-color: #c0392b;
        }
        
        .question-list {
            margin-top: 20px;
        }
        
        .question-card {
            background-color: var(--white);
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            border-left: 4px solid var(--primary-color);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        
        .question-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
        }
        
        .question-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .question-header h4 {
            color: var(--primary-color);
            font-size: 18px;
            margin: 0;
        }
        
        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
            background-color: var(--light-gray);
            color: var(--dark-gray);
        }
        
        .question-text {
            margin-bottom: 15px;
            font-size: 16px;
            line-height: 1.5;
        }
        
        .question-options {
            margin-left: 20px;
        }
        
        .question-option {
            margin-bottom: 8px;
            padding: 8px 12px;
            background-color: var(--light-gray);
            border-radius: 4px;
            position: relative;
        }
        
        .question-option.correct {
            background-color: #d4edda;
            border-left: 3px solid var(--success-color);
        }
        
        .question-meta {
            display: flex;
            gap: 15px;
            font-size: 14px;
            color: var(--dark-gray);
            margin-top: 15px;
            flex-wrap: wrap;
        }
        
        .question-meta span {
            display: flex;
            align-items: center;
        }
        
        .question-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
            justify-content: flex-end;
        }
        
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid var(--medium-gray);
            text-align: center;
            color: var(--dark-gray);
            font-size: 14px;
        }
        
        .footer p {
            margin-bottom: 5px;
        }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .container {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
                padding: 15px;
            }
            
            .main-content {
                padding: 20px;
            }
            
            .question-filters {
                flex-direction: column;
                gap: 10px;
            }
            
            .filter-group {
                width: 100%;
            }
            
            .question-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            
            .question-meta {
                flex-direction: column;
                gap: 8px;
            }
        }
        
        /* Additional styles for the form */
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid var(--medium-gray);
            border-radius: 4px;
            font-size: 14px;
        }
        
        textarea.form-control {
            min-height: 100px;
        }
        
        .form-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }        
        /* New styles for test selector */
        .test-selector {
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .test-selector select {
            flex: 1;
            padding: 8px;
            border-radius: 4px;
            border: 1px solid var(--medium-gray);
        }
        
        .test-selector button {
            padding: 8px 15px;
        }
        
        /* MCQ options styles */
        .mcq-options-container {
            display: none;
            margin-top: 15px;
        }
        
        .option-row {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .option-letter {
            width: 30px;
            font-weight: bold;
        }
        
        .option-input {
            flex: 1;
        }
        
        .add-option-btn {
            margin-top: 10px;
        }
        
        .remove-option-btn {
            margin-left: 10px;
            color: var(--danger-color);
            cursor: pointer;
        }
        
        .test-info {
            font-size: 0.9em;
            color: var(--secondary-color);
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Sidebar Navigation -->
        <div class="sidebar">
            <h2>Quizefy System</h2>
            <ul class="sidebar-menu">
                <li><a href="index.jsp">Dashboard</a></li>
                <li><a href="assessments.jsp">Manage Assessments</a></li>
                <li><a href="manageTests.jsp">Manage Tests</a></li>
                <li><a href="users.jsp">Manage Users</a></li>
                <li><a href="reports.jsp">Performance Reports</a></li>
                <li><a href="questions.jsp" class="active">Question Bank</a></li>
            </ul>
        </div>

        <div class="main-content">
            <header>
                <h1 class="page-title">Question Bank</h1>
                <div class="user-info">
                    <span>Admin User</span>
                    <div class="user-avatar">AU</div>
                </div>
            </header>

            <% if (error != null) { %>
                <div style="color: var(--danger-color); margin-bottom: 20px; padding: 10px; background-color: #f8d7da; border-radius: 4px;">
                    <%= error %>
                </div>
            <% } %>

            <% if (successMessage != null) { %>
                <div style="color: var(--success-color); margin-bottom: 20px; padding: 10px; background-color: #d4edda; border-radius: 4px;">
                    <%= successMessage %>
                </div>
            <% } %>

            <!-- Test Selector -->
            <div class="test-selector">
                <select id="testSelector">
                    <option value="">-- Select a Test --</option>
                    <% for (Test test : tests) { %>
                        <option value="<%= test.getId() %>" <%= testId != null && testId.equals(String.valueOf(test.getId())) ? "selected" : "" %>>
                            <%= test.getTitle() %>
                        </option>
                    <% } %>
                </select>
                <button class="btn btn-primary" onclick="createQuestionForTest()">Create Question for Selected Test</button>
            </div>

            <% if (testId != null) { %>
                <div class="test-info">
                    Currently viewing questions for: 
                    <% for (Test test : tests) { %>
                        <% if (test.getId() == Integer.parseInt(testId)) { %>
                            <strong><%= test.getTitle() %></strong>
                        <% } %>
                    <% } %>
                </div>
            <% } %>

            <div class="card">
                <div class="tab-container">
                    <div class="tabs">
                        <a href="questions.jsp?tab=all<%= testId != null ? "&test_id=" + testId : "" %>" class="tab <%= "all".equals(activeTab) ? "active" : "" %>">All Questions</a>
                        <a href="questions.jsp?tab=MCQ<%= testId != null ? "&test_id=" + testId : "" %>" class="tab <%= "MCQ".equals(activeTab) ? "active" : "" %>">Multiple Choice</a>
                        <a href="questions.jsp?tab=Text<%= testId != null ? "&test_id=" + testId : "" %>" class="tab <%= "Text".equals(activeTab) ? "active" : "" %>">Text Answer</a>
                        <a href="questions.jsp?tab=Coding<%= testId != null ? "&test_id=" + testId : "" %>" class="tab <%= "Coding".equals(activeTab) ? "active" : "" %>">Coding</a>
                    </div>
                </div>

                <form method="get" action="questions.jsp" class="question-filters">
                    <input type="hidden" name="tab" value="<%= activeTab %>">
                    <% if (testId != null) { %>
                        <input type="hidden" name="test_id" value="<%= testId %>">
                    <% } %>
                    <div class="filter-group">
                        <label for="difficultyFilter">Difficulty</label>
                        <select id="difficultyFilter" name="difficulty" class="form-control" onchange="this.form.submit()">
                            <option value="all">All Levels</option>
                            <option value="1" <%= "1".equals(difficultyFilter) ? "selected" : "" %>>Easy (1-3)</option>
                            <option value="4" <%= "4".equals(difficultyFilter) ? "selected" : "" %>>Medium (4-7)</option>
                            <option value="8" <%= "8".equals(difficultyFilter) ? "selected" : "" %>>Hard (8-10)</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label for="searchFilter">Search</label>
                        <input type="text" id="searchFilter" name="search" class="form-control" 
                               placeholder="Search questions..." value="<%= searchQuery != null ? searchQuery : "" %>">
                    </div>
                    <button type="submit" style="display: none;"></button>
                </form>

                <button class="btn btn-primary" onclick="document.getElementById('questionForm').style.display='block'">
                    + Add New Question
                </button>

                <!-- Question Form -->
                <div class="card" id="questionForm" style="display: <%= questionToEdit != null ? "block" : "none" %>; margin-bottom: 20px;">
                    <h3><%= questionToEdit != null ? "Edit Question" : "Create New Question" %></h3>
                    <form method="post" action="questions.jsp?tab=<%= activeTab %><%= testId != null ? "&test_id=" + testId : "" %>">
                        <% if (questionToEdit != null) { %>
                            <input type="hidden" name="question_id" value="<%= questionToEdit.getId() %>">
                        <% } %>
                        
                        <input type="hidden" name="test_id" id="form_test_id" value="<%= testId != null ? testId : "" %>">
                        
                        <div class="form-group">
                            <label for="text">Question Text</label>
                            <textarea name="text" id="text" class="form-control" required><%= questionToEdit != null ? questionToEdit.getText() : "" %></textarea>
                        </div>

                        <div class="form-group">
                            <label for="question_type">Question Type</label>
                            <select name="question_type" id="question_type" class="form-control" required onchange="toggleMCQOptions()">
                                <option value="">-- Select Type --</option>
                                <option value="MCQ" <%= questionToEdit != null && "MCQ".equals(questionToEdit.getQuestionType()) ? "selected" : "" %>>Multiple Choice</option>
                                <option value="Text" <%= questionToEdit != null && "Text".equals(questionToEdit.getQuestionType()) ? "selected" : "" %>>Text Answer</option>
                                <option value="Coding" <%= questionToEdit != null && "Coding".equals(questionToEdit.getQuestionType()) ? "selected" : "" %>>Coding</option>
                            </select>
                        </div>

                        <!-- MCQ Options Container -->
                        <div id="mcqOptionsContainer" class="mcq-options-container">
                            <h4>Multiple Choice Options</h4>
                            <div id="optionsContainer">
                                <!-- Options will be added here dynamically -->
                            </div>
                            <button type="button" class="btn btn-primary add-option-btn" onclick="addOption()">+ Add Option</button>
                        </div>

                        <div class="form-group">
                            <label for="difficulty">Difficulty (1-10)</label>
                            <input type="number" name="difficulty" id="difficulty" class="form-control" 
                                   min="1" max="10" value="<%= questionToEdit != null ? questionToEdit.getDifficulty() : "5" %>" required>
                        </div>

                        <div class="form-group">
                            <label for="weight">Weight</label>
                            <input type="number" step="0.1" name="weight" id="weight" class="form-control" 
                                   value="<%= questionToEdit != null ? questionToEdit.getWeight() : "1.0" %>" required>
                        </div>

                        <!-- Hidden field to store formatted correct answer -->
                        <input type="hidden" name="correct_answer" id="correct_answer" value="">

                        <div class="form-actions">
                            <button class="btn btn-primary" type="submit">
                                <%= questionToEdit != null ? "Update Question" : "Create Question" %>
                            </button>
                            <button class="btn" type="button" onclick="document.getElementById('questionForm').style.display='none'">
                                Cancel
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Question List -->
                <div class="question-list">
                    <% for (Question q : questions) { 
                        String difficultyClass = "";
                        if (q.getDifficulty() <= 3) {
                            difficultyClass = "Easy";
                        } else if (q.getDifficulty() <= 7) {
                            difficultyClass = "Medium";
                        } else {
                            difficultyClass = "Hard";
                        }
                    %>
                        <div class="question-card">
                            <div class="question-header">
                                <h4><%= q.getText().length() > 50 ? q.getText().substring(0, 50) + "..." : q.getText() %></h4>
                                <span class="badge">Difficulty: <%= difficultyClass %></span>
                            </div>
                            <div class="question-text">
                                <%= q.getText() %>
                                <% 
try {
    java.lang.reflect.Method getTestTitle = q.getClass().getMethod("getTestTitle");
    String testTitle = (String)getTestTitle.invoke(q);
    if (testTitle != null) { %>
        <div class="test-info">Test: <%= testTitle %></div>
    <% }
} catch (Exception e) {
    // Method doesn't exist, skip it
}
%>
                            </div>
                            <% if ("MCQ".equals(q.getQuestionType())) { 
                                String[] options = q.getCorrectAnswer().split("\\|");
                            %>
                                <div class="question-options">
                                    <% for (String option : options) { 
                                        String[] parts = option.split("\\) ");
                                        String letter = parts[0];
                                        String text = parts.length > 1 ? parts[1] : "";
                                    %>
                                        <div class="question-option">
                                            <%= letter %>) <%= text %>
                                        </div>
                                    <% } %>
                                </div>
                            <% } %>
                            <div class="question-meta">
                                <span>Type: <%= q.getQuestionType() %></span>
                                <span>Weight: <%= q.getWeight() %></span>
                            </div>
                            <div class="question-actions">
                                <a href="questions.jsp?edit_id=<%= q.getId() %>&tab=<%= activeTab %><%= testId != null ? "&test_id=" + testId : "" %>" class="btn btn-sm btn-primary">Edit</a>
                                <a href="questions.jsp?delete_id=<%= q.getId() %>&tab=<%= activeTab %><%= testId != null ? "&test_id=" + testId : "" %>" 
                                   class="btn btn-sm btn-danger" 
                                   onclick="return confirm('Are you sure you want to delete this question?')">Delete</a>
                            </div>
                        </div>
                    <% } %>
                    
                    <% if (questions.isEmpty()) { %>
                        <div style="text-align: center; padding: 20px; color: var(--dark-gray);">
                            No questions found matching your criteria.
                        </div>
                    <% } %>
                </div>
            </div>

            <div class="footer">
                <p>Support | Documentation</p>
                <p>© 2025 Assessment System</p>
            </div>
        </div>
    </div>

    <script>
        // Show/hide form when clicking Add New Question
        document.querySelector('.btn-primary').addEventListener('click', function() {
            document.getElementById('questionForm').style.display = 'block';
        });
        
        // Auto-submit search when typing
        document.getElementById('searchFilter').addEventListener('keyup', function(e) {
            if (e.key === 'Enter') {
                this.form.submit();
            }
        });
        
        // Create question for selected test
        function createQuestionForTest() {
            const testSelector = document.getElementById('testSelector');
            const selectedTestId = testSelector.value;
            
            if (selectedTestId) {
                // Set the test ID in the form
                document.getElementById('form_test_id').value = selectedTestId;
                
                // Show the question form
                document.getElementById('questionForm').style.display = 'block';
                
                // Reset form if not editing
                <% if (questionToEdit == null) { %>
                    document.querySelector('#questionForm form').reset();
                    document.getElementById('optionsContainer').innerHTML = '';
                <% } %>
                
                // Scroll to the form
                document.getElementById('questionForm').scrollIntoView({ behavior: 'smooth' });
            } else {
                alert('Please select a test first');
            }
        }
        
        // Toggle MCQ options based on question type
        function toggleMCQOptions() {
            const questionType = document.getElementById('question_type').value;
            const mcqContainer = document.getElementById('mcqOptionsContainer');
            
            if (questionType === 'MCQ') {
                mcqContainer.style.display = 'block';
                // Initialize with 4 options if empty
                if (document.getElementById('optionsContainer').children.length === 0) {
                    for (let i = 0; i < 4; i++) {
                        addOption(String.fromCharCode(65 + i));
                    }
                }
            } else {
                mcqContainer.style.display = 'none';
            }
        }
        
        // Add new option
        function addOption(letter = null) {
            const container = document.getElementById('optionsContainer');
            const optionCount = container.children.length;
            const optionLetter = letter || String.fromCharCode(65 + optionCount);
            
            const optionRow = document.createElement('div');
            optionRow.className = 'option-row';
            optionRow.innerHTML = `
                <div class="option-letter">${optionLetter})</div>
                <input type="hidden" name="options" value="${optionLetter}">
                <input type="text" name="option_text" class="form-control option-input" placeholder="Option text" required>
                <span class="remove-option-btn" onclick="this.parentElement.remove()">×</span>
            `;
            
            container.appendChild(optionRow);
        }
        
        // Format MCQ options before submission
        document.querySelector('form').addEventListener('submit', function(e) {
            const questionType = document.getElementById('question_type').value;
            
            if (questionType === 'MCQ') {
                const options = document.getElementsByName('options');
                const optionTexts = document.getElementsByName('option_text');
                let correctAnswer = '';
                
                for (let i = 0; i < options.length; i++) {
                    correctAnswer += options[i].value + ') ' + optionTexts[i].value;
                    if (i < options.length - 1) {
                        correctAnswer += '|';
                    }
                }
                
                document.getElementById('correct_answer').value = correctAnswer;
            }
        });
        
        // Initialize MCQ options if editing an MCQ question
        <% if (questionToEdit != null && "MCQ".equals(questionToEdit.getQuestionType())) { %>
            window.onload = function() {
                document.getElementById('question_type').dispatchEvent(new Event('change'));
                const options = '<%= questionToEdit.getCorrectAnswer() %>'.split('|');
                const container = document.getElementById('optionsContainer');
                container.innerHTML = '';
                
                options.forEach(option => {
                    const parts = option.split(') ');
                    const letter = parts[0];
                    const text = parts.length > 1 ? parts[1] : '';
                    addOption(letter);
                    
                    // Set the option text
                    const inputs = container.getElementsByTagName('input');
                    inputs[inputs.length - 1].value = text;
                });
            };
        <% } %>
    </script>
</body>
</html>