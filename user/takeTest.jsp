<%@ page import="my_pack.AssessmentManager, java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Initialize variables
    int assessmentId = 0;
    String assessmentName = "";
    List<Map<String, String>> questions = new ArrayList<>();
    Map<Integer, List<Map<String, String>>> questionOptions = new HashMap<>();
    String errorMessage = null;
    
    try {
        String idParam = request.getParameter("assessment_id");
        if (idParam == null || idParam.trim().isEmpty()) {
            errorMessage = "Assessment ID is missing";
        } else {
            assessmentId = Integer.parseInt(idParam);
            AssessmentManager manager = new AssessmentManager();
            
            // Get assessment name
            Map<String, String> assessment = manager.getAssessmentById(assessmentId);
            if (assessment != null) {
                assessmentName = assessment.get("name");
            }
            
            // Get all questions for all tests in this assessment
            List<Map<String, String>> tests = manager.getTestsForAssessment(assessmentId);
            for (Map<String, String> test : tests) {
                int testId = Integer.parseInt(test.get("id"));
                List<Map<String, String>> testQuestions = manager.getQuestionsByTestId(testId);
                questions.addAll(testQuestions);
                
                // Get options for each question
                for (Map<String, String> question : testQuestions) {
                    int questionId = Integer.parseInt(question.get("id"));
                    List<Map<String, String>> options = manager.getQuestionOptions(questionId);
                    questionOptions.put(questionId, options);
                }
            }
            
            if (questions.isEmpty()) {
                errorMessage = "No questions found for this assessment";
            }
        }
    } catch (NumberFormatException e) {
        errorMessage = "Invalid assessment ID format";
    } catch (Exception e) {
        errorMessage = "An error occurred: " + e.getMessage();
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title><%= assessmentName %> - Test</title>
    <style>
        :root {
            --primary-color: #3498db;
            --secondary-color: #2980b9;
            --light-gray: #f5f5f5;
            --medium-gray: #e0e0e0;
            --dark-gray: #333;
            --white: #ffffff;
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
        
        .test-header {
            background-color: var(--white);
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .test-title {
            color: var(--primary-color);
            margin-bottom: 5px;
        }
        
        .test-assessment {
            color: var(--dark-gray);
            font-size: 1rem;
        }
        
        .questions-container {
            background-color: var(--white);
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            padding: 20px;
        }
        
        .question {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .question:last-child {
            border-bottom: none;
        }
        
        .question-text {
            font-weight: 600;
            margin-bottom: 15px;
        }
        
        .question-meta {
            font-size: 0.9rem;
            color: var(--dark-gray);
            margin-bottom: 15px;
        }
        
        .options-list {
            list-style-type: none;
            padding-left: 0;
        }
        
        .option-item {
            margin-bottom: 10px;
            padding: 8px;
            border-radius: 4px;
            background-color: var(--light-gray);
        }
        
        .option-item:hover {
            background-color: var(--medium-gray);
        }
        
        .option-input {
            margin-right: 10px;
        }
        
        .text-answer {
            width: 100%;
            padding: 10px;
            border: 1px solid var(--medium-gray);
            border-radius: 5px;
            font-size: 16px;
            margin-top: 10px;
        }
        
        .submit-btn {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
            transition: background-color 0.3s;
        }
        
        .submit-btn:hover {
            background-color: var(--secondary-color);
        }
        
        .timer {
            text-align: right;
            margin-bottom: 20px;
            font-weight: 600;
            color: var(--primary-color);
            font-size: 1.2rem;
        }
        
        .error-message {
            background-color: #ffebee;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            color: #c62828;
        }
        
        .back-link {
            display: inline-block;
            margin-top: 15px;
            color: var(--primary-color);
            text-decoration: none;
        }
        
        .back-link:hover {
            text-decoration: underline;
        }
    </style>
    <script>
        // Timer for 30 minutes
        let timeLeft = 30 * 60;
        const timerElement = document.getElementById('timer');
        const timerDisplay = document.getElementById('timer-display');
        
        function updateTimer() {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            const displayText = `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
            
            timerElement.textContent = displayText;
            timerDisplay.textContent = displayText;
            
            if (timeLeft <= 0) {
                document.getElementById('testForm').submit();
            } else {
                timeLeft--;
                setTimeout(updateTimer, 1000);
            }
        }
        
        document.addEventListener('DOMContentLoaded', function() {
            updateTimer();
        });
    </script>
</head>
<body>
    <div class="container">
        <% if (errorMessage != null) { %>
            <div class="error-message">
                <h2>Error</h2>
                <p><%= errorMessage %></p>
                <a href="homepage.jsp" class="back-link">← Back to Home</a>
            </div>
        <% } else { %>
            <div class="timer" id="timer">30:00</div>
            
            <div class="test-header">
                <h1 class="test-title"><%= assessmentName %></h1>
                <p class="test-assessment">Time remaining: <span id="timer-display">30:00</span></p>
            </div>
            
            <form id="testForm" action="submitTest.jsp" method="post">
                <input type="hidden" name="assessment_id" value="<%= assessmentId %>">
                <input type="hidden" name="user_id" value="<%= session.getAttribute("userId") != null ? session.getAttribute("userId") : "" %>">
                
                <% for (int i = 0; i < questions.size(); i++) { 
                    Map<String, String> question = questions.get(i);
                    int questionId = Integer.parseInt(question.get("id"));
                    List<Map<String, String>> options = questionOptions.get(questionId);
                %>
                    <div class="question">
                        <div class="question-text">Q<%= i+1 %>. <%= question.get("text") %></div>
                        <div class="question-meta">
                            Type: <%= question.get("type") %> | 
                            Difficulty: <%= question.get("difficulty") %>/10
                        </div>
                        
                        <% if ("MCQ".equals(question.get("type"))) { %>
                            <ul class="options-list">
                                <% for (Map<String, String> option : options) { %>
                                    <li class="option-item">
                                        <input type="radio" 
                                               name="q_<%= questionId %>" 
                                               id="q<%= questionId %>_<%= option.get("id") %>" 
                                               value="<%= option.get("id") %>" 
                                               class="option-input" required>
                                        <label for="q<%= questionId %>_<%= option.get("id") %>">
                                            <%= option.get("option_text") %>
                                        </label>
                                    </li>
                                <% } %>
                            </ul>
                        <% } else { %>
                            <textarea name="q_<%= questionId %>" class="text-answer" rows="4" required></textarea>
                        <% } %>
                    </div>
                <% } %>
                
                <button type="submit" class="submit-btn">Submit Assessment</button>
            </form>
        <% } %>
    </div>
</body>
</html>