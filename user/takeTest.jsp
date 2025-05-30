<%@ page import="my_pack.AssessmentManager, java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Initialize variables
    int assessmentId = 0;
    String assessmentName = "";
    List<Map<String, String>> questions = new ArrayList<>();
    List<Map<String, String>> tests = new ArrayList<>();

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
            
            tests = manager.getTestsForAssessment(assessmentId);
            
            for (Map<String, String> test : tests) {
                int testId = Integer.parseInt(test.get("id"));
                List<Map<String, String>> testQuestions = manager.getQuestionsByTestId(testId);
                questions.addAll(testQuestions);
                
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
        
        .test-header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .test-title {
            color: var(--primary-color);
            margin-bottom: 10px;
            font-size: 24px;
        }
        
        .timer-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .timer {
            font-weight: 600;
            color: var(--danger-color);
            font-size: 18px;
        }
        
        .progress-indicator {
            font-weight: 500;
            color: var(--dark-gray);
        }
        
        .question {
            margin-bottom: 30px;
            padding: 20px;
            border-radius: 8px;
            background-color: var(--white);
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border-left: 4px solid var(--primary-color);
            display: none;
        }
        
        .question.active {
            display: block;
        }
        
        .question-text {
            font-weight: 600;
            margin-bottom: 15px;
            font-size: 18px;
            color: var(--dark-gray);
        }
        
        .question-meta {
            font-size: 0.9rem;
            color: #666;
            margin-bottom: 20px;
            display: flex;
            gap: 15px;
        }
        
        .options-list {
            list-style-type: none;
            padding-left: 0;
            margin-top: 15px;
        }
        
        .option-item {
            margin-bottom: 10px;
            padding: 12px 15px;
            border-radius: 6px;
            background-color: var(--light-gray);
            transition: all 0.2s;
            cursor: pointer;
        }
        
        .option-item:hover {
            background-color: #e3f2fd;
        }
        
        .option-item.selected {
            background-color: #bbdefb;
            border-left: 3px solid var(--primary-color);
        }
        
        .option-input {
            margin-right: 10px;
            cursor: pointer;
        }
        
        .text-answer {
            width: 100%;
            padding: 12px;
            border: 1px solid var(--medium-gray);
            border-radius: 6px;
            font-size: 16px;
            margin-top: 10px;
            resize: vertical;
            min-height: 100px;
        }
        
        .btn-container {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            color: white;
        }
        
        .btn-primary:hover {
            background-color: var(--secondary-color);
        }
        
        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid var(--danger-color);
        }
        
        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 500;
        }
        
        .back-link:hover {
            text-decoration: underline;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 20px;
            }
            
            .btn-container {
                flex-direction: column;
                gap: 10px;
            }
            
            .btn {
                width: 100%;
            }
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
            <div class="test-header">
                <h1 class="test-title"><%= assessmentName %></h1>
            </div>
            
            <div class="timer-container">
                <div class="timer" id="timer">Time remaining: 30:00</div>
                <div class="progress-indicator" id="progress-indicator">Question 1 of <%= questions.size() %></div>
            </div>
            
            <form id="testForm" action="submitTest.jsp" method="post">
                <input type="hidden" name="assessment_id" value="<%= assessmentId %>">
                <% 
                StringBuilder testIds = new StringBuilder();
                for (int i = 0; i < tests.size(); i++) {
                    if (i > 0) testIds.append(",");
                    testIds.append(tests.get(i).get("id"));
                }
                %>
                <input type="hidden" name="testIds" value="<%= testIds.toString() %>">
                <input type="hidden" name="user_id" value="<%= session.getAttribute("userId") != null ? session.getAttribute("userId") : "" %>">
                
                <% for (int i = 0; i < questions.size(); i++) { 
                    Map<String, String> question = questions.get(i);
                    int questionId = Integer.parseInt(question.get("id"));
                    String testId = question.get("test_id");
                    List<Map<String, String>> options = questionOptions.get(questionId);
                %>
                    <div class="question <%= i == 0 ? "active" : "" %>" id="question-<%= i+1 %>">
                        <input type="hidden" name="q_<%= questionId %>_test" value="<%= testId %>">
                        
                        <div class="question-text">
                            Q<%= i+1 %>. <%= question.get("text") %>
                        </div>
                        <div class="question-meta">
                            <span>Type: <%= question.get("type") %></span>
                            <span>Difficulty: <%= question.get("difficulty") %>/10</span>
                        </div>
                        
                        <% if ("MCQ".equals(question.get("type"))) { %>
                            <ul class="options-list">
                                <% for (Map<String, String> option : options) { %>
                                    <li class="option-item" onclick="selectOption(this)">
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
                            <textarea name="q_<%= questionId %>" class="text-answer" rows="4" placeholder="Type your answer here..."></textarea>
                        <% } %>
                    </div>
                <% } %>
                
                <div class="btn-container">
                    <button type="button" class="btn btn-secondary" id="prev-btn" style="display: none;">Previous</button>
                    <button type="button" class="btn btn-primary" id="next-btn">Next Question</button>
                    <button type="submit" class="btn btn-primary" id="submit-btn" style="display: none;">Submit Assessment</button>
                </div>
            </form>
        <% } %>
    </div>
    
    <script>
        // Timer for 30 minutes
        let timeLeft = 30 * 60;
        const timerElement = document.getElementById('timer');
        
        function updateTimer() {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            const displayText = `Time remaining: ${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
            
            timerElement.textContent = displayText;
            
            if (timeLeft <= 0) {
                document.getElementById('testForm').submit();
            } else {
                timeLeft--;
                setTimeout(updateTimer, 1000);
            }
        }
        
        function selectOption(optionItem) {
            const radioInput = optionItem.querySelector('input[type="radio"]');
            radioInput.checked = true;
            
            // Update UI
            document.querySelectorAll('.option-item').forEach(item => {
                item.classList.remove('selected');
            });
            optionItem.classList.add('selected');
        }
        
        document.addEventListener('DOMContentLoaded', function() {
            updateTimer();
            
            // Question navigation logic
            const questions = document.querySelectorAll('.question');
            const prevBtn = document.getElementById('prev-btn');
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
                
                // Show/hide navigation buttons
                if (currentQuestion > 0) {
                    prevBtn.style.display = 'inline-block';
                }
                
                if (currentQuestion === questions.length - 1) {
                    nextBtn.style.display = 'none';
                    submitBtn.style.display = 'inline-block';
                }
            });
            
            prevBtn.addEventListener('click', function() {
                // Move to previous question
                currentQuestion--;
                showQuestion(currentQuestion);
                
                // Show/hide navigation buttons
                if (currentQuestion === 0) {
                    prevBtn.style.display = 'none';
                }
                
                if (currentQuestion < questions.length - 1) {
                    nextBtn.style.display = 'inline-block';
                    submitBtn.style.display = 'none';
                }
            });
            
            function showQuestion(index) {
                // Hide all questions
                questions.forEach(q => q.classList.remove('active'));
                
                // Show current question
                questions[index].classList.add('active');
                
                // Update progress indicator
                progressIndicator.textContent = `Question ${index + 1} of ${questions.length}`;
                
                // Scroll to question
                questions[index].scrollIntoView({ behavior: 'smooth', block: 'start' });
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