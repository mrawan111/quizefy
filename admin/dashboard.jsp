<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assessment System - Dashboard</title>
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
        }
        
        .card-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .card {
            background-color: var(--white);
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        
        .card h3 {
            margin-bottom: 15px;
            color: var(--primary-color);
        }
        
        .system-overview {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background-color: var(--white);
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        
        .stat-card .number {
            font-size: 36px;
            font-weight: bold;
            color: var(--primary-color);
            margin: 10px 0;
        }
        
        .stat-card .label {
            color: var(--dark-gray);
            font-size: 14px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid var(--medium-gray);
            border-radius: 5px;
            font-size: 16px;
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 500;
            transition: background-color 0.3s ease;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            color: var(--white);
        }
        
        .btn-primary:hover {
            background-color: var(--secondary-color);
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        
        table th, table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        table th {
            background-color: var(--light-gray);
            font-weight: 600;
        }
        
        table tr:hover {
            background-color: var(--light-gray);
        }
        
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid var(--medium-gray);
            text-align: center;
            color: var(--dark-gray);
            font-size: 14px;
        }
        
        .divider {
            height: 1px;
            background-color: var(--medium-gray);
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
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

        <!-- Main Content Area -->
        <div class="main-content">
            <header>
                <h1 class="page-title">Dashboard</h1>
                <div class="user-info">
                    <span>Admin User</span>
                    <div class="user-avatar">AU</div>
                </div>
            </header>

            <!-- System Overview Cards -->
            <div class="system-overview">
                <div class="stat-card">
                    <div class="number">125</div>
                    <div class="label">Total Users</div>
                </div>
                <div class="stat-card">
                    <div class="number">58</div>
                    <div class="label">Assessments Created</div>
                </div>
                <div class="stat-card">
                    <div class="number">8</div>
                    <div class="label">Recruiters Registered</div>
                </div>
            </div>

   
            <!-- Recent Assessments Table -->
            <div class="card">
                <h3>Recent Assessments</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Assessment Name</th>
                            <th>Date Created</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>JavaScript Basics</td>
                            <td>10/27/2023</td>
                        </tr>
                        <tr>
                            <td>Python Intermediate</td>
                            <td>10/25/2023</td>
                        </tr>
                        <tr>
                            <td>React Essentials</td>
                            <td>10/20/2023</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="divider"></div>

            <!-- Recent Activities Table -->
            <div class="card">
                <h3>Recent Activities</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Action</th>
                            <th>User</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Created Assessment</td>
                            <td>Recruiter_01</td>
                            <td>04/10/2025</td>
                        </tr>
                        <tr>
                            <td>Added New User</td>
                            <td>Admin_03</td>
                            <td>04/03/2025</td>
                        </tr>
                        <tr>
                            <td>Removed Candidate</td>
                            <td>Admin_02</td>
                            <td>04/02/2025</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="footer">
                <p>Support | Documentation</p>
                <p>© 2025 Assessment System</p>
            </div>
        </div>
    </div>
</body>
</html>