<%@ page import="my_pack.AssessmentManager, java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Initialize variables
    int assessmentId = 0;
    String assessmentName = "";
    List<Map<String, String>> questions = new ArrayList<>();
    List<Map<String, String>> tests = new ArrayList<>();  // <-- declare here, empty list as default

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
        
        // FIX: Actually load the tests for this assessment
        tests = manager.getTestsForAssessment(assessmentId);
        
        // Now process each test
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
            display: none; /* Hide all questions by default */
        }
        
        .question.active {
            display: block; /* Show only active question */
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
            display: none; /* Hide submit button by default */
        }
        
        .submit-btn:hover {
            background-color: var(--secondary-color);
        }
        
        .next-btn {
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
        
        .next-btn:hover {
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
        
        .progress-indicator {
            text-align: center;
            margin-bottom: 20px;
            font-weight: 600;
        }
    </style>
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
            
            <div class="progress-indicator" id="progress-indicator">
                Question 1 of <%= questions.size() %>
            </div>
            
            <form id="testForm" action="submitTest.jsp" method="post">
                <input type="hidden" name="assessment_id" value="<%= assessmentId %>">
                <% if (!tests.isEmpty()) { %>
                    <input type="hidden" name="testId" value="<%= tests.get(0).get("id") %>">
                <% } %>
                <input type="hidden" name="user_id" value="<%= session.getAttribute("userId") != null ? session.getAttribute("userId") : "" %>">
                
                <% for (int i = 0; i < questions.size(); i++) { 
                    Map<String, String> question = questions.get(i);
                    int questionId = Integer.parseInt(question.get("id"));
                    List<Map<String, String>> options = questionOptions.get(questionId);
                %>
                    <div class="question <%= i == 0 ? "active" : "" %>" id="question-<%= i+1 %>">
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
                                               class="option-input">
                                        <label for="q<%= questionId %>_<%= option.get("id") %>">
                                            <%= option.get("option_text") %>
                                        </label>
                                    </li>
                                <% } %>
                            </ul>
                        <% } else { %>
                            <textarea name="q_<%= questionId %>" class="text-answer" rows="4"></textarea>
                        <% } %>
                    </div>
                <% } %>
                
                <button type="button" class="next-btn" id="next-btn">Next Question</button>
                <button type="submit" class="submit-btn" id="submit-btn">Submit Assessment</button>
            </form>
        <% } %>
    </div>
    
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
            
            // Question navigation logic
            const questions = document.querySelectorAll('.question');
            const nextBtn = document.getElementById('next-btn');
            const submitBtn = document.getElementById('submit-btn');
            const progressIndicator = document.getElementById('progress-indicator');
            let currentQuestion = 0;
            
            // Initialize first question
            showQuestion(currentQuestion);
            
            nextBtn.addEventListener('click', function() {
                // Move to next question
                currentQuestion++;
                showQuestion(currentQuestion);
                
                // If we're on the last question, show submit button and hide next button
                if (currentQuestion === questions.length - 1) {
                    nextBtn.style.display = 'none';
                    submitBtn.style.display = 'inline-block';
                }
            });
            
            function showQuestion(index) {
                // Hide all questions
                questions.forEach(q => q.classList.remove('active'));
                
                // Show current question
                questions[index].classList.add('active');
                
                // Update progress indicator
                progressIndicator.textContent = `Question ${index + 1} of ${questions.length}`;
            }
        });
        
        // Form submission confirmation
        document.getElementById('testForm').addEventListener('submit', function(e) {
            const unanswered = [];
            const questions = document.querySelectorAll('.question');
            
            questions.forEach((question, index) => {
                const questionNumber = index + 1;
                const hasRadio = question.querySelector('input[type="radio"]') !== null;
                const hasTextarea = question.querySelector('textarea') !== null;
                
                if (hasRadio && question.querySelector('input[type="radio"]:checked') === null) {
                    unanswered.push(questionNumber);
                } else if (hasTextarea && question.querySelector('textarea').value.trim() === '') {
                    unanswered.push(questionNumber);
                }
            });
            
            if (unanswered.length > 0) {
                e.preventDefault();
                const confirmSubmit = confirm(`You haven't answered questions: ${unanswered.join(', ')}. Submit anyway?`);
                if (confirmSubmit) {
                    this.submit();
                }
            }
        });
    </script>
</body>
</html>