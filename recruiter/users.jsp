<%@ page import="java.sql.*" %>
<%@ page import="my_pack.DBConnection" %>

<%
    // Handle form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Handle new user creation
        if (request.getParameter("createUser") != null) {
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String role = request.getParameter("role");
            
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, name);
                stmt.setString(2, email);
                stmt.setString(3, password);
                stmt.setString(4, role);
                stmt.executeUpdate();
            } catch (Exception e) {
                out.println("<p style='color:red'>Error creating user: " + e.getMessage() + "</p>");
            }
        }
        // Handle role update separately
        else if (request.getParameter("updateRole") != null) {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String newRole = request.getParameter("newRole");
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "UPDATE users SET role = ? WHERE id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, newRole);
                stmt.setInt(2, userId);
                stmt.executeUpdate();
            } catch (Exception e) {
                out.println("<p style='color:red'>Error updating role: " + e.getMessage() + "</p>");
            }
        }
    }

    // Handle deletion
    if (request.getParameter("delete") != null) {
        int id = Integer.parseInt(request.getParameter("delete"));
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "DELETE FROM users WHERE id = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, id);
            stmt.executeUpdate();
        } catch (Exception e) {
            out.println("<p style='color:red'>Error: " + e.getMessage() + "</p>");
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Assessment System - User Management</title>
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
        
        .user-table-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .user-table-actions h3 {
            color: var(--dark-gray);
            font-size: 18px;
            margin: 0;
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
        
        select.form-control[multiple] {
            height: auto;
            min-height: 100px;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        table th, table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        table th {
            background-color: var(--light-gray);
            font-weight: 600;
            color: var(--dark-gray);
        }
        
        table tr:hover {
            background-color: var(--light-gray);
        }
        
        .user-avatar-sm {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background-color: var(--medium-gray);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: bold;
            color: var(--dark-gray);
        }
        
        .role-badge {
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block;
        }
        
        .role-admin {
            background-color: #d1ecf1;
            color: #0c5460;
        }
        
        .role-recruiter {
            background-color: #d4edda;
            color: #155724;
        }
        
        .role-candidate {
            background-color: #fff3cd;
            color: #856404;
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
        
        /* Modal styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.4);
        }
        
        .modal-content {
            background-color: #fefefe;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 50%;
            border-radius: 8px;
        }
        
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        
        .close:hover {
            color: black;
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
            
            .user-table-actions {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            
            table {
                display: block;
                overflow-x: auto;
                white-space: nowrap;
            }
            
            .form-control {
                width: 100%;
            }
            
            .modal-content {
                width: 90%;
            }
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
                <li><a href="users.jsp">Manage Users</a></li>
                <li><a href="reports.jsp">Performance Reports</a></li>
            </ul>
        </div>

        <div class="main-content">
            <header>
                <h1 class="page-title">User Management</h1>
                <div class="user-info">
                    <span>Admin User</span>
                    <div class="user-avatar">AU</div>
                </div>
            </header>

            <div class="card">
                <div class="user-table-actions">
                    <h3>All Users</h3>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>User</th>
                            <th>Email</th>
                            <th>Role</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery("SELECT * FROM users");
                                while (rs.next()) {
                                    String roleClass = "";
                                    switch(rs.getString("role")) {
                                        case "admin":
                                            roleClass = "role-admin";
                                            break;
                                        case "recruiter":
                                            roleClass = "role-recruiter";
                                            break;
                                        case "candidate":
                                            roleClass = "role-candidate";
                                            break;
                                    }
                                    
                                    // Get initials for avatar
                                    String name = rs.getString("name");
                                    String[] nameParts = name.split(" ");
                                    String initials = "";
                                    for (String part : nameParts) {
                                        if (!part.isEmpty()) {
                                            initials += part.substring(0, 1).toUpperCase();
                                        }
                                    }
                                    if (initials.length() > 2) {
                                        initials = initials.substring(0, 2);
                                    }
                        %>
                        <tr>
                            <td>
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <div class="user-avatar-sm"><%= initials %></div>
                                    <span><%= name %></span>
                                </div>
                            </td>
                            <td><%= rs.getString("email") %></td>
                            <td><span class="role-badge <%= roleClass %>"><%= rs.getString("role") %></span></td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='3'>Error loading users: " + e.getMessage() + "</td></tr>");
                            }
                        %>
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