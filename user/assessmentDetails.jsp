<%@ page import="my_pack.AssessmentManager, my_pack.DBConnection, java.util.*, java.sql.*,java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Initialize variables
    Map<String, String> assessment = new HashMap<>();
    List<Map<String, String>> tests = new ArrayList<>();
    String errorMessage = null;
    
    try {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            errorMessage = "Assessment ID is missing";
        } else {
            int assessmentId = Integer.parseInt(idParam);
            AssessmentManager manager = new AssessmentManager();
            assessment = manager.getAssessmentById(assessmentId);
            
            if (assessment == null || assessment.isEmpty()) {
                errorMessage = "Assessment not found with ID: " + assessmentId;
            } else {
                // Get only tests for this assessment (not questions yet)
                tests = manager.getTestsForAssessment(assessmentId);
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
    <title><%= errorMessage != null ? "Error" : assessment.get("name") + " - Questions Preview" %></title>
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
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .assessment-header {
            background-color: var(--white);
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .assessment-title {
            color: var(--primary-color);
            margin-bottom: 10px;
        }
        
        .assessment-description {
            margin-bottom: 20px;
        }
        
        .questions-container {
            background-color: var(--white);
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .test-section {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .test-section:last-child {
            border-bottom: none;
        }
        
        .test-title {
            color: var(--primary-color);
            margin-bottom: 15px;
        }
        
        .question {
            margin-bottom: 20px;
            padding: 15px;
            background-color: var(--light-gray);
            border-radius: 5px;
        }
        
        .question-text {
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .question-meta {
            font-size: 0.9rem;
            color: var(--dark-gray);
        }
        
        .start-test-btn {
            display: block;
            width: 200px;
            margin: 30px auto;
            padding: 12px;
            background-color: var(--primary-color);
            color: white;
            text-align: center;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
        }
        
        .start-test-btn:hover {
            background-color: var(--secondary-color);
        }
        
        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: var(--primary-color);
            text-decoration: none;
        }
        
        .error-message {
            color: #e74c3c;
            padding: 20px;
            background-color: #fdecea;
            border-radius: 5px;
            margin: 20px 0;
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
            <div class="assessment-header">
                <h1 class="assessment-title"><%= assessment.get("name") %></h1>
                <p class="assessment-description"><%= assessment.get("description") %></p>
            </div>
            
            <div class="questions-container">
                <h2>Tests Preview</h2>
                
                <% if (tests.isEmpty()) { %>
                    <p>No tests available for this assessment.</p>
                <% } else { %>
                    <% for (Map<String, String> test : tests) { %>
                        <div class="test-section">
                            <h3 class="test-title"><%= test.get("title") %></h3>
                            <div class="test-meta">
                                Created: <%= test.get("created_date") %> | 
                                Difficulty: <%= test.get("target_difficulty") %>/10
                            </div>
                        </div>
                    <% } %>
                <% } %>
            </div>
            
            <form action="takeTest.jsp" method="get">
                <input type="hidden" name="assessment_id" value="<%= request.getParameter("id") %>">
                <button type="submit" class="start-test-btn">Start Assessment</button>
            </form>
            
            <a href="homepage.jsp" class="back-link">← Back to Home</a>
        <% } %>
    </div>
</body>
</html>