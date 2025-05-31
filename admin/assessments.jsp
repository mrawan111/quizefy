<%@ page import="my_pack.AssessmentManager" %>
<%@ page import="java.util.*" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    AssessmentManager manager = new AssessmentManager();
    String error = null;
    String success = null;

    // Handle form submissions
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        
       if ("add".equals(action)) {
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        if (manager.addAssessment(name, description, userId)) {
            success = "Assessment added successfully!";
        } else {
            error = "Failed to add assessment";
        }
    }
        else if ("update".equals(action)) {
            String idStr = request.getParameter("id");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            
            try {
                int id = Integer.parseInt(idStr);
                if (manager.updateAssessment(id, name, description)) {
                    success = "Assessment updated successfully!";
                } else {
                    error = "Failed to update assessment";
                }
            } catch (NumberFormatException e) {
            }
        }
        else if ("delete".equals(action)) {
            String idStr = request.getParameter("id");
            
            try {
                int id = Integer.parseInt(idStr);
                if (manager.deleteAssessment(id)) {
                    success = "Assessment deleted successfully!";
                } else {
                    error = "Failed to delete assessment";
                }
            } catch (NumberFormatException e) {
                error = "Invalid assessment ID";
            }
        }
        
        if (error == null && success != null) {
            response.sendRedirect("assessments.jsp");
            return;
        }
    }

    // Get assessments for display
    List<Map<String, String>> assessments = manager.getAllAssessments();
    
    // Check if editing
    String editId = request.getParameter("edit");
    Map<String, String> editAssessment = null;
    if (editId != null) {
        try {
            int id = Integer.parseInt(editId);
            editAssessment = manager.getAssessmentById(id);
        } catch (NumberFormatException e) {
        }
    }
%>
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
            --draft-color: #95a5a6;
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
            grid-template-columns: 1fr;
            gap: 15px;
            margin-top: 20px;
        }
        
        .assessment-item {
            background-color: var(--white);
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            border-left: 4px solid var(--primary-color);
        }
        
        .assessment-item h4 {
            margin-bottom: 5px;
            color: var(--primary-color);
            font-size: 18px;
        }
        
        .assessment-item .meta {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
        }
        
        .assessment-item p {
            color: var(--dark-gray);
            font-size: 14px;
            margin-bottom: 15px;
            line-height: 1.5;
        }
        
        .assessment-item .actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }
        
        .status-active {
            color: var(--success-color);
            font-weight: 500;
        }
        
        .status-draft {
            color: var(--draft-color);
            font-weight: 500;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-size: 14px;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
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
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="sidebar">
            <h2>Quizefy System</h2>
            <ul class="sidebar-menu">
                <li><a href="index.jsp">Dashboard</a></li>
                <li><a href="assessments.jsp" class="active">Manage Assessments</a></li>
                <li><a href="manageTests.jsp">Manage Tests</a></li>
                <li><a href="users.jsp">Manage Users</a></li>
                <li><a href="reports.jsp">Performance Reports</a></li>
                <li><a href="questions.jsp">Question Bank</a></li>
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

            <% if (error != null) { %>
                <div class="alert alert-danger"><%= error %></div>
            <% } %>
            
            <% if (success != null) { %>
                <div class="alert alert-success"><%= success %></div>
            <% } %>

            <div class="card">
                <div class="assessment-actions">
                    <h3>All Assessments</h3>
                    <a href="assessments.jsp?edit=new" class="btn btn-primary">+ Create Assessment</a>
                </div>

                <% if (editAssessment != null || "new".equals(editId)) { %>
                    <div class="card" style="margin-bottom: 20px;">
                        <h3><%= editAssessment != null ? "Edit Assessment" : "Create New Assessment" %></h3>
                        <form method="post">
                            <input type="hidden" name="action" value="<%= editAssessment != null ? "update" : "add" %>">
                            <% if (editAssessment != null) { %>
                                <input type="hidden" name="id" value="<%= editAssessment.get("id") %>">
                            <% } %>
                            
                            <div class="form-group">
                                <label>Assessment Name</label>
                                <input type="text" name="name" class="form-control" 
                                       placeholder="e.g., JavaScript Fundamentals Test"
                                       value="<%= editAssessment != null ? editAssessment.get("name") : "" %>" required>
                            </div>
                            
                            <div class="form-group">
                                <label>Description</label>
                                <textarea name="description" class="form-control" required><%= 
                                    editAssessment != null ? editAssessment.get("description") : "" %></textarea>
                            </div>
                            
                            <div style="display: flex; gap: 10px;">
                                <button type="submit" class="btn btn-primary">
                                    <%= editAssessment != null ? "Update" : "Save" %> Assessment
                                </button>
                                <a href="assessments.jsp" class="btn">Cancel</a>
                            </div>
                        </form>
                    </div>
                <% } %>

                <div class="assessment-list">
                    <% if (assessments.isEmpty()) { %>
                        <div class="card">
                            <p>No assessments found. Create your first assessment!</p>
                        </div>
                    <% } else { %>
                        <% for (Map<String, String> a : assessments) { %>
                            <div class="assessment-item">
                                <h4><%= a.get("name") %></h4>
                                <div class="meta">
                                    <span>ID: <%= a.get("id") %></span>
                                    <span class="status-active">Active</span>
                                </div>
                                <p><%= a.get("description") %></p>
                                <div class="actions">
                                    <a href="assessments.jsp?edit=<%= a.get("id") %>" class="btn btn-sm btn-primary">Edit</a>
                                    <form method="post" style="display: inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= a.get("id") %>">
                                        <button type="submit" class="btn btn-sm btn-danger" 
                                            onclick="return confirm('Are you sure you want to delete this assessment?')">Delete</button>
                                    </form>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                </div>
            </div>

            <div class="footer">
                <p>Support | Documentation</p>
                <p>© 2025 Quizefy System</p>
            </div>
        </div>
    </div>
</body>
</html>