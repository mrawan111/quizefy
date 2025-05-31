<%@ page import="my_pack.UserManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign Up - Quizefy</title>
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
        input[type="text"], input[type="email"], input[type="password"] {
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

<div class="header">Quizefy</div>

<div class="container">
    <div class="login-box">
        <h2>Sign Up</h2>
        <form method="post">
            <input type="text" name="name" placeholder="Username" required>
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <input type="submit" value="Sign Up">
        </form>
        <div class="signup-link">
            Already have an account? <a href="login.jsp">Login here</a>
        </div>

        <%
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String password = request.getParameter("password");

            if (name != null && email != null && password != null) {
                UserManager um = new UserManager();
                boolean success = um.registerUser(name, email, password);

                if (success) {
                    out.println("<p style='color:green;text-align:center;'>Sign-up successful! <a href='login.jsp'>Login</a></p>");
                } else {
                    out.println("<p style='color:red;text-align:center;'>Sign-up failed. Email might already be used.</p>");
                }
            }
        %>
    </div>
</div>

</body>
</html>
