<%@ page import="my_pack.UserManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Handle successful login
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Your existing login logic
        
        // After successful login
        String redirectUrl = (String) session.getAttribute("redirectAfterLogin");
        if (redirectUrl != null) {
            session.removeAttribute("redirectAfterLogin");
            response.sendRedirect(redirectUrl);
            return;
        } else {
            response.sendRedirect("homepage.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login - Test Track</title>
    <style>
        body {
            background-color: #f0f8ff;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }
        .header {
            background-color: #e3f2fd;
            text-align: center;
            padding: 15px;
            font-size: 24px;
            color: #1976d2;
            font-weight: bold;
        }
        .container {
            margin-top: 80px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .login-box {
            background-color: #ffffff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.1);
            width: 320px;
        }
        .login-box h2 {
            text-align: center;
            margin-bottom: 20px;
            color: #1976d2;
        }
        input[type="email"], input[type="password"] {
            width: 100%;
            padding: 10px;
            margin: 8px 0;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
        }
        input[type="submit"] {
            width: 100%;
            background-color: #42a5f5;
            color: white;
            padding: 10px;
            margin-top: 10px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
        }
        input[type="submit"]:hover {
            background-color: #1e88e5;
        }
        .signup-link {
            text-align: center;
            margin-top: 15px;
            font-size: 14px;
        }
        .signup-link a {
            color: #1976d2;
            text-decoration: none;
        }
        .signup-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="header">Test Track</div>

<div class="container">
    <div class="login-box">
        <h2>Login</h2>
        <form method="post">
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <input type="submit" value="Login">
        </form>
        <div class="signup-link">
            Don't have an account? <a href="signup.jsp">Sign up here</a>
        </div>

        <%
            String email = request.getParameter("email");
            String password = request.getParameter("password");

            if (email != null && password != null) {
                UserManager um = new UserManager();
                boolean success = um.loginUser(email, password);

                if (success) {
                    // Assuming getUserId, getUserRole, and getUserName are methods in UserManager
                    Integer userId = um.getUserId(email, password);
                    String role = um.getUserRole(email, password);
                    String name = um.getUserName(email, password);

                    session.setAttribute("userEmail", email);
                    session.setAttribute("userName", name);
                    session.setAttribute("userRole", role);
                    session.setAttribute("userId", userId);  // Save userId to session

                    if ("admin".equals(role)  ) {
                        response.sendRedirect("admin/index.jsp");
                    }else if("recruiter".equals(role)){
                        response.sendRedirect("recruiter/index.jsp");
                    } 
                    else if ("candidate".equals(role)) {
                        response.sendRedirect("user/homepage.jsp");
                    } else {
                        out.println("<p style='color:red;text-align:center;'>Unknown role. Contact admin.</p>");
                    }
                } else {
                    out.println("<p style='color:red;text-align:center;'>Invalid email or password.</p>");
                }
            }
        %>
    </div>
</div>

</body>
</html>
