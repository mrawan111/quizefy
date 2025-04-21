<!DOCTYPE html>
<html lang="en">
<head>
    <title>Assessment System - Manage Assessments</title>
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
        
        .assessment-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .assessment-actions h3 {
            color: var(--dark-gray);
            font-size: 18px;
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
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid var(--medium-gray);
            border-radius: 5px;
            font-size: 16px;
        }
        
        textarea.form-control {
            min-height: 100px;
            resize: vertical;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }
        
        .assessment-list {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .assessment-card {
            background-color: var(--white);
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            border-left: 4px solid var(--primary-color);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        
        .assessment-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
        }
        
        .assessment-card h4 {
            margin-bottom: 10px;
            color: var(--primary-color);
            font-size: 18px;
        }
        
        .assessment-card p {
            color: var(--dark-gray);
            font-size: 14px;
            margin-bottom: 15px;
            line-height: 1.5;
        }
        
        .assessment-card .meta {
            display: flex;
            justify-content: space-between;
            font-size: 13px;
            color: #666;
            margin-bottom: 15px;
        }
        
        .assessment-card .actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }
        
        .status-active {
            color: var(--success-color);
            font-weight: 500;
        }
        
        .status-inactive {
            color: var(--danger-color);
            font-weight: 500;
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
            
            .assessment-actions {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            
            .assessment-list {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
       <div class="sidebar">
            <h2>Quizefy System</h2>
            <ul class="sidebar-menu">
                <li><a href="index.html" class="active">Dashboard</a></li>
                <li><a href="assessments.html">Manage Assessments</a></li>
                <li><a href="manageTests.html">Manage Tests</a></li>
                <li><a href="users.html">Manage Users</a></li>
                <li><a href="reports.html">Performance Reports</a></li>
                <li><a href="questions.html">Question Bank</a></li>
            </ul>
        </div>

        <div class="main-content">
            <header>
                <h1 class="page-title">Manage Assessments</h1>
                <div class="user-info">
                    <span>Admin User</span>
                    <div class="user-avatar">AU</div>
                </div>
            </header>

            <div class="card">
                <div class="assessment-actions">
                    <h3>All Assessments</h3>
                    
                    <button class="btn btn-primary" id="addAssessmentBtn">+ Create Assessment</button>
                </div>

                <!-- Assessment Creation Form (initially hidden) -->
                <div class="card" id="assessmentForm" style="display: none; margin-bottom: 20px;">
                    <h3>Create New Assessment</h3>
                    <div class="form-group">
                        <label for="assessmentName">Assessment Name</label>
                        <input type="text" id="assessmentName" class="form-control" placeholder="e.g., JavaScript Fundamentals Test">
                    </div>
                    <div class="form-group">
                        <label for="assessmentModule">Module</label>
                        <select id="assessmentModule" class="form-control">
                            <option value="js">JavaScript Basics</option>
                            <option value="python">Python Intermediate</option>
                            <option value="react">React Essentials</option>
                            <option value="db">Database Design</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="assessmentDesc">Description</label>
                        <textarea id="assessmentDesc" class="form-control" rows="3" placeholder="Assessment description"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="assessmentDuration">Duration (minutes)</label>
                        <input type="number" id="assessmentDuration" class="form-control" value="30" min="5">
                    </div>
                    <button class="btn btn-primary">Save Assessment</button>
                    <button class="btn" onclick="document.getElementById('assessmentForm').style.display='none'">Cancel</button>
                </div>

                <!-- Assessment List -->
                <div class="assessment-list">
                    <div class="assessment-card">
                        <h4>JavaScript Basics</h4>
                        <div class="meta">
                            <span>Module: JavaScript</span>
                            <span class="status-active">Active</span>
                        </div>
                        <p>Test knowledge of JavaScript fundamentals including variables, functions, and basic DOM manipulation.</p>
                        <div class="actions">
                            <button class="btn btn-sm btn-primary">Edit</button>
                            <button class="btn btn-sm btn-warning">Duplicate</button>
                            <button class="btn btn-sm btn-danger">Archive</button>
                        </div>
                    </div>
                    <div class="assessment-card">
                        <h4>Python Intermediate</h4>
                        <div class="meta">
                            <span>Module: Python</span>
                            <span class="status-active">Active</span>
                        </div>
                        <p>Assess intermediate Python skills including list comprehensions, decorators, and file handling.</p>
                        <div class="actions">
                            <button class="btn btn-sm btn-primary">Edit</button>
                            <button class="btn btn-sm btn-warning">Duplicate</button>
                            <button class="btn btn-sm btn-danger">Archive</button>
                        </div>
                    </div>
                    <div class="assessment-card">
                        <h4>Database Design</h4>
                        <div class="meta">
                            <span>Module: Database</span>
                            <span class="status-active">Active</span>
                        </div>
                        <p>Evaluate understanding of relational database concepts, normalization, and SQL queries.</p>
                        <div class="actions">
                            <button class="btn btn-sm btn-primary">Edit</button>
                            <button class="btn btn-sm btn-warning">Duplicate</button>
                            <button class="btn btn-sm btn-danger">Archive</button>
                        </div>
                    </div>
                    <div class="assessment-card">
                        <h4>React Essentials</h4>
                        <div class="meta">
                            <span>Module: React</span>
                            <span class="status-inactive">Draft</span>
                        </div>
                        <p>Test React knowledge including components, state management, and hooks.</p>
                        <div class="actions">
                            <button class="btn btn-sm btn-primary">Edit</button>
                            <button class="btn btn-sm btn-warning">Duplicate</button>
                            <button class="btn btn-sm btn-danger">Archive</button>
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
        document.getElementById('addAssessmentBtn').addEventListener('click', function() {
            document.getElementById('assessmentForm').style.display = 'block';
        });
    </script>
</body>
</html>