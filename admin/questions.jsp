<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="my_pack.Question" %>
<%@ page import="my_pack.Test" %>
<%@ page import="my_pack.DBConnection" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    List<Question> questions = new ArrayList<>();
    List<Test> tests = new ArrayList<>();
    String error = null;
    String successMessage = null;
    String searchQuery = request.getParameter("search");
    String difficultyFilter = request.getParameter("difficulty");
    String testId = request.getParameter("test_id");

    // Load all tests
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
    }

    // Handle form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String text = request.getParameter("text");
        String[] options = request.getParameterValues("options");
        String correctOption = request.getParameter("correct_option");
        String difficulty = request.getParameter("difficulty");
        String weight = request.getParameter("weight");
        String questionId = request.getParameter("question_id");
        String testIdParam = request.getParameter("test_id");

        try {
            // Convert options to pipe-separated string
            String optionsText = String.join("|", options);
            
            if (questionId != null && !questionId.isEmpty()) {
                stmt = conn.prepareStatement(
                    "UPDATE questions SET text=?, question_type=?, difficulty=?, weight=?, " +
                    "test_id=?, options_text=?, correct_option=? WHERE id=?"
                );
                stmt.setInt(8, Integer.parseInt(questionId));
            } else {
                stmt = conn.prepareStatement(
                    "INSERT INTO questions (text, question_type, difficulty, weight, " +
                    "test_id, options_text, correct_option) VALUES (?, ?, ?, ?, ?, ?, ?)"
                );
            }
            
            stmt.setString(1, text);
            stmt.setString(2, "MCQ");
            stmt.setInt(3, Integer.parseInt(difficulty));
            stmt.setFloat(4, Float.parseFloat(weight));
            stmt.setInt(5, Integer.parseInt(testIdParam));
            stmt.setString(6, optionsText);
            System.out.println("Correct option value: " + correctOption); // Add this line

            stmt.setString(7, correctOption);
            
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                successMessage = questionId != null ? 
                    "Question updated successfully!" : "Question created successfully!";
                response.sendRedirect("questions.jsp?test_id=" + testIdParam);
                return;
            }
        } catch (Exception e) {
            error = "Error saving question: " + e.getMessage();
        } finally {
            if (stmt != null) stmt.close();
        }
    }

    // Delete question
    String deleteId = request.getParameter("delete_id");
    if (deleteId != null) {
        try {
            stmt = conn.prepareStatement("DELETE FROM questions WHERE id = ?");
            stmt.setInt(1, Integer.parseInt(deleteId));
            stmt.executeUpdate();
            successMessage = "Question deleted successfully!";
        } catch (Exception e) {
            error = "Error deleting question: " + e.getMessage();
        } finally {
            if (stmt != null) stmt.close();
        }
    }

    // Load questions
    try {
        StringBuilder query = new StringBuilder(
            "SELECT q.*, t.title as test_title FROM questions q LEFT JOIN tests t ON q.test_id = t.id " +
            "WHERE q.question_type = 'MCQ'"
        );
        
        if (searchQuery != null && !searchQuery.isEmpty()) {
            query.append(" AND q.text LIKE ?");
        }
        if (difficultyFilter != null && !"all".equals(difficultyFilter)) {
            query.append(" AND q.difficulty = ?");
        }
        if (testId != null && !testId.isEmpty()) {
            query.append(" AND q.test_id = ?");
        }
        
        stmt = conn.prepareStatement(query.toString());
        int paramIndex = 1;
        
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
            question.setWeight(rs.getFloat("weight"));
            question.setOptionsText(rs.getString("options_text"));
            question.setCorrectOption(rs.getString("correct_option").charAt(0));
            question.setTestId(rs.getInt("test_id"));
            question.setTestTitle(rs.getString("test_title"));
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
                questionToEdit.setWeight(rs.getFloat("weight"));
                questionToEdit.setOptionsText(rs.getString("options_text"));
                questionToEdit.setCorrectOption(rs.getString("correct_option").charAt(0));
                questionToEdit.setTestId(rs.getInt("test_id"));
            }
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
    <title>Question Bank</title>
    <style>

        /* All CSS styles remain exactly the same as previous version */
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
        /* Styles for the options container */
#optionsContainer {
    margin-top: 20px;
}

/* Each option's row */
.option-row {
    display: flex;
    align-items: center;
    margin-bottom: 15px;
    gap: 15px;
}

/* Input field for the option text */
.option-row input[type="text"] {
    flex: 1;
    padding: 10px;
    border: 1px solid var(--medium-gray);
    border-radius: 5px;
    font-size: 16px;
}

/* Label for the option text */
.option-row label {
    margin-bottom: 8px;
    font-weight: 500;
    color: var(--dark-gray);
}

/* Radio button for the correct option */
.option-row input[type="radio"] {
    margin-right: 10px;
}

/* Correct option indicator text */
.correct-option-indicator {
    color: var(--success-color);
    font-weight: bold;
}

/* Remove button for the option */
.option-row button {
    background-color: var(--danger-color);
    color: var(--white);
    border: none;
    padding: 8px 12px;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

.option-row button:hover {
    background-color: #c0392b;
}
/* Style for the radio buttons (correct option) */
.option-row input[type="radio"] {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    border: 2px solid var(--primary-color);
    background-color: var(--white);
    appearance: none;
    transition: all 0.3s ease;
    cursor: pointer;
}

/* Hover effect for the radio button */
.option-row input[type="radio"]:hover {
    border-color: var(--secondary-color);
}

/* Checked state (selected radio button) */
.option-row input[type="radio"]:checked {
    background-color: var(--primary-color);
    border-color: var(--primary-color);
}

/* When the radio button is checked, the indicator color changes */
.option-row input[type="radio"]:checked::before {
    content: "";
    display: block;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background-color: var(--white);
    margin: 3px;
}

/* Optional: If you want to add a hover effect or style when focus */
.option-row input[type="radio"]:focus {
    outline: none;
    box-shadow: 0 0 5px var(--primary-color);
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
        
        .question-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
            justify-content: flex-end;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .option-row {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
            gap: 10px;
        }
        
        .option-row input[type="text"] {
            flex: 1;
        }
        
        .correct-option-indicator {
            color: var(--success-color);
            font-weight: bold;
            margin-left: 10px;
        }
        
        .test-selector {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            align-items: center;
        }
        
        .test-selector select {
            flex: 1;
        }
        
        @media (max-width: 768px) {
            .container {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
            }
            
            .question-filters {
                flex-direction: column;
            }
        }
        /* ... rest of the CSS remains unchanged ... */
        
        .option-row {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
            gap: 10px;
        }
        
        .option-row input[type="text"] {
            flex: 1;
        }
        
        .correct-option-indicator {
            color: var(--success-color);
            font-weight: bold;
            margin-left: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="sidebar">
            <h2>Quizefy System</h2>
            <ul class="sidebar-menu">
                <li><a href="index.jsp">Dashboard</a></li>
                <li><a href="assessments.jsp">Assessments</a></li>
                <li><a href="manageTests.jsp">Tests</a></li>
                <li><a href="users.jsp">Users</a></li>
                <li><a href="reports.jsp">Reports</a></li>
                <li><a href="questions.jsp" class="active">Question Bank</a></li>
            </ul>
        </div>

        <div class="main-content">
            <header>
                <h1 class="page-title">Question Bank</h1>
                <div class="user-info">
                    <span>Admin</span>
                    <div class="user-avatar">A</div>
                </div>
            </header>

            <% if (error != null) { %>
                <div class="card" style="background-color: #f8d7da; color: var(--danger-color);">
                    <%= error %>
                </div>
            <% } %>

            <% if (successMessage != null) { %>
                <div class="card" style="background-color: #d4edda; color: var(--success-color);">
                    <%= successMessage %>
                </div>
            <% } %>

            <div class="test-selector">
                <select id="testSelector" class="form-control">
                    <option value="">-- Select a Test --</option>
                    <% for (Test test : tests) { %>
                        <option value="<%= test.getId() %>" 
                            <%= testId != null && testId.equals(String.valueOf(test.getId())) ? "selected" : "" %>>
                            <%= test.getTitle() %>
                        </option>
                    <% } %>
                </select>
                <button class="btn btn-primary" onclick="showQuestionForm()">Create Question</button>
            </div>

            <% if (testId != null) { %>
                <div class="card" style="margin-bottom: 20px;">
                    Currently viewing questions for: 
                    <% for (Test test : tests) { %>
                        <% if (test.getId() == Integer.parseInt(testId)) { %>
                            <strong><%= test.getTitle() %></strong>
                        <% } %>
                    <% } %>
                </div>
            <% } %>

            <div class="card">
                <form method="get" action="questions.jsp" class="question-filters">
                    <input type="hidden" name="tab" value="MCQ">
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
                </form>
            </div>

            <div class="card" id="questionForm" style="display: <%= questionToEdit != null ? "block" : "none" %>;">
                <h3><%= questionToEdit != null ? "Edit Question" : "Create New Question" %></h3>
                <form method="post" onsubmit="return validateForm()">
                    <% if (questionToEdit != null) { %>
                        <input type="hidden" name="question_id" value="<%= questionToEdit.getId() %>">
                    <% } %>
                    <input type="hidden" name="test_id" id="form_test_id" value="<%= testId != null ? testId : "" %>">
                    
                    <div class="form-group">
                        <label>Question Text</label>
                        <textarea name="text" class="form-control" required><%= questionToEdit != null ? questionToEdit.getText() : "" %></textarea>
                    </div>

                    <div class="form-group">
                        <label>Options</label>
                       <div id="optionsContainer">
    <!-- Option A -->
    <div class="option-row">
        <input type="text" name="options" placeholder="Option A" required>
    </div>
    <!-- Option B -->
    <div class="option-row">
        <input type="text" name="options" placeholder="Option B" required>
    </div>
    <!-- Option C (Optional) -->
    <div class="option-row">
        <input type="text" name="options" placeholder="Option C">
    </div>
    <!-- Option D (Optional) -->
    <div class="option-row">
        <input type="text" name="options" placeholder="Option D">
    </div>
</div>

<!-- Dropdown to select the correct option -->
<label for="correct_option">Select Correct Answer</label>
<select id="correct_option" name="correct_option" required>
    <option value="" disabled selected>Select Correct Answer</option>
    <option value="A">Option A</option>
    <option value="B">Option B</option>
    <option value="C">Option C</option>
    <option value="D">Option D</option>
</select>

                        <button type="button" class="btn btn-primary" onclick="addOption()">+ Add Option</button>
                    </div>

                    <div class="form-group">
                        <label>Difficulty (1-10)</label>
                        <input type="number" name="difficulty" class="form-control" min="1" max="10" 
                               value="<%= questionToEdit != null ? questionToEdit.getDifficulty() : "5" %>" required>
                    </div>

                    <div class="form-group">
                        <label>Weight</label>
                        <input type="number" step="0.1" name="weight" class="form-control" 
                               value="<%= questionToEdit != null ? questionToEdit.getWeight() : "1.0" %>" required>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Save Question</button>
                        <button type="button" class="btn" onclick="hideQuestionForm()">Cancel</button>
                    </div>
                </form>
            </div>

            <div class="question-list">
                <% for (Question q : questions) { 
                    String[] options = q.getOptionsText().split("\\|");
                %>
                    <div class="question-card">
                        <div class="question-header">
                            <h4><%= q.getText() %></h4>
                            <span class="badge">
                                Difficulty: <%= q.getDifficulty() %>
                            </span>
                        </div>
                        
                        <% if (q.getTestTitle() != null) { %>
                            <div class="test-info">Test: <%= q.getTestTitle() %></div>
                        <% } %>
                        
                        <div class="question-options">
                            <% for (int i = 0; i < options.length; i++) { 
                                char letter = (char)('A' + i);
                                boolean isCorrect = (letter == q.getCorrectOption());
                            %>
                                <div class="question-option <%= isCorrect ? "correct" : "" %>">
                                    <%= letter %>) <%= options[i] %>
                                    <% if (isCorrect) { %>
                                        <span class="correct-option-indicator">✓ Correct</span>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>
                        
                        <div class="question-meta">
                            <span>Weight: <%= q.getWeight() %></span>
                        </div>
                        
                        <div class="question-actions">
                            <a href="questions.jsp?edit_id=<%= q.getId() %><%= testId != null ? "&test_id=" + testId : "" %>" 
                               class="btn btn-sm btn-primary">Edit</a>
                            <a href="questions.jsp?delete_id=<%= q.getId() %><%= testId != null ? "&test_id=" + testId : "" %>" 
                               class="btn btn-sm btn-danger" 
                               onclick="return confirm('Are you sure you want to delete this question?')">Delete</a>
                        </div>
                    </div>
                <% } %>
                
                <% if (questions.isEmpty()) { %>
                    <div class="card" style="text-align: center;">
                        No questions found matching your criteria.
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
   function addOption(letter, text, isCorrect) {
    const container = document.getElementById('optionsContainer');
    const optionCount = container.children.length;
    const optionLetter = letter || String.fromCharCode(65 + optionCount);
    const optionText = text || '';
    
    const optionRow = document.createElement('div');
    optionRow.className = 'option-row';
    optionRow.innerHTML = `
        <input type="text" name="options" value="${optionText}" placeholder="Option ${optionLetter}" required>
        <input type="radio" name="correct_option" value="${optionLetter}" ${isCorrect ? 'checked' : ''} required>
        <label>Correct Answer</label>
        <button type="button" onclick="removeOption(this)" class="btn btn-sm btn-danger">×</button>
    `;
    
    container.appendChild(optionRow);
}

function removeOption(button) {
    const container = document.getElementById('optionsContainer');
    if (container.children.length > 2) {
        button.parentElement.remove();
        // Renumber remaining options
        const options = container.querySelectorAll('.option-row');
        options.forEach((row, index) => {
            const letter = String.fromCharCode(65 + index);
            row.querySelector('input[type="text"]').placeholder = `Option ${letter}`;
            row.querySelector('input[type="radio"]').value = letter;
        });
    } else {
        alert("Questions must have at least 2 options");
    }
}
function validateForm() {
    const options = document.querySelectorAll('input[name="options"]');
    const correctOption = document.getElementById('correct_option').value;
    
    // Validate at least 2 options
    if (options.length < 2) {
        alert("Please provide at least 2 options");
        return false;
    }

    // Validate all options have text
    for (let i = 0; i < options.length; i++) {
        if (!options[i].value.trim()) {
            alert("Please fill in all option texts");
            options[i].focus();
            return false;
        }
    }

    // Validate correct option selected
    if (!correctOption) {
        alert("Please select the correct answer");
        return false;
    }

    return true;
}

function showQuestionForm() {
    const testId = document.getElementById('testSelector').value;
    if (!testId) {
        alert("Please select a test first");
        return;
    }
    document.getElementById('form_test_id').value = testId;
    document.getElementById('questionForm').style.display = 'block';
    document.getElementById('questionForm').scrollIntoView({ behavior: 'smooth' });
}

function hideQuestionForm() {
    document.getElementById('questionForm').style.display = 'none';
}

    </script>
</body>
</html>