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
    </style>
</head>
<body>
    <div class="container">
        <!-- Sidebar Navigation -->
<div class="sidebar">
            <h2>Quizefy System</h2>
            <ul class="sidebar-menu">
                <li><a href="index.jsp" class="active">Dashboard</a></li>
                <li><a href="assessments.jsp">Manage Assessments</a></li>
                <li><a href="manageTests.jsp">Manage Tests</a></li>
                <li><a href="users.jsp">Manage Users</a></li>
                <li><a href="reports.jsp">Performance Reports</a></li>
                <li><a href="questions.jsp">Question Bank</a></li>
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

            <div class="card">
                <div class="tab-container">
                    <div class="tabs">
                        <div class="tab active">All Questions</div>
                        <div class="tab">Multiple Choice</div>
                        <div class="tab">Text Answer</div>
                        <div class="tab">Coding</div>
                    </div>
                </div>

                <div class="question-filters">
                    <div class="filter-group">
                        <label for="moduleFilter">Module</label>
                        <select id="moduleFilter" class="form-control">
                            <option value="all">All Modules</option>
                            <option value="js">JavaScript</option>
                            <option value="python">Python</option>
                            <option value="react">React</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label for="difficultyFilter">Difficulty</label>
                        <select id="difficultyFilter" class="form-control">
                            <option value="all">All Levels</option>
                            <option value="easy">Easy</option>
                            <option value="medium">Medium</option>
                            <option value="hard">Hard</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label for="searchFilter">Search</label>
                        <input type="text" id="searchFilter" class="form-control" placeholder="Search questions...">
                    </div>
                </div>

                <button class="btn btn-primary">+ Add New Question</button>
<div class="card" id="questionForm" style="display: none; margin-bottom: 20px;">
                    <h3>Create New question</h3>
                    <div class="form-group">
                        <label for="questionName">question Name</label>
                        <input type="text" id="questionName" class="form-control" placeholder="e.g., JavaScript Fundamentals Test">
                    </div>
                    <div class="form-group">
                        <label for="questionModule">question</label>
                        <select id="questionModule" class="form-control">
                            <option value="js">JavaScript Basics</option>
                            <option value="python">Python Intermediate</option>
                            <option value="react">React Essentials</option>
                            <option value="db">Database Design</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="questionDesc">Description</label>
                        <textarea id="questionDesc" class="form-control" rows="3" placeholder="question description"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="questionDuration">Duration (minutes)</label>
                        <input type="number" id="questionDuration" class="form-control" value="30" min="5">
                    </div>
                    <button class="btn btn-primary">Save question</button>
                    <button class="btn" onclick="document.getElementById('questionForm').style.display='none'">Cancel</button>
                </div>
                <div class="question-list">
                    <div class="question-card">
                        <div class="question-header">
                            <h4>JavaScript Closure</h4>
                            <span class="badge">Difficulty: Medium</span>
                        </div>
                        <div class="question-text">
                            What is a closure in JavaScript?
                        </div>
                        <div class="question-options">
                            <div class="question-option">A function that has access to its outer function's scope</div>
                            <div class="question-option correct">A combination of a function and the lexical environment within which it was declared</div>
                            <div class="question-option">A built-in JavaScript method</div>
                            <div class="question-option">A type of JavaScript loop</div>
                        </div>
                        <div class="question-meta">
                            <span>Module: JavaScript Basics</span>
                            <span>Weight: 1.5</span>
                            <span>Created: 10/15/2023</span>
                        </div>
                        <div class="question-actions">
                            <button class="btn btn-sm btn-primary">Edit</button>
                            <button class="btn btn-sm btn-warning">Duplicate</button>
                            <button class="btn btn-sm btn-danger">Delete</button>
                        </div>
                    </div>

                    <div class="question-card">
                        <div class="question-header">
                            <h4>Python List Comprehension</h4>
                            <span class="badge">Difficulty: Easy</span>
                        </div>
                        <div class="question-text">
                            Write a list comprehension that squares each number in the range 0 to 9.
                        </div>
                        <div class="question-meta">
                            <span>Module: Python Intermediate</span>
                            <span>Weight: 1.0</span>
                            <span>Created: 10/10/2023</span>
                        </div>
                        <div class="question-actions">
                            <button class="btn btn-sm btn-primary">Edit</button>
                            <button class="btn btn-sm btn-warning">Duplicate</button>
                            <button class="btn btn-sm btn-danger">Delete</button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="footer">
                <p>Support | Documentation</p>
                <p>© 2025 Assessment System</p>
            </div>
        </div>
    </div>
  <script>
    document.querySelector('.btn-primary').addEventListener('click', function () {
        document.getElementById('questionForm').style.display = 'block';
    });
</script>

</body>
</html>