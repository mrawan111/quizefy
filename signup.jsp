<!DOCTYPE html>
<html>
<head>
    <title>Test Track - Sign Up</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            background-color: #f5fefe;
            font-family: Arial, sans-serif;
        }
        .header {
            background-color: #eaf6fd;
            padding: 10px;
            text-align: center;
            font-size: 20px;
            font-weight: bold;
            color: #3498db;
            border-bottom: 1px solid #ddd;
        }
        .box {
            width: 300px;
            margin: 100px auto;
            padding: 20px;
            background-color: #f0f8ff;
            border-radius: 10px;
            box-shadow: 0 0 10px #a1cfff;
            text-align: center;
        }
        .box h2 {
            color: #3498db;
        }
        .box input {
            width: 90%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .box button {
            background-color: #3498db;
            color: white;
            padding: 10px 15px;
            border: none;
            width: 100%;
            margin-top: 10px;
            cursor: pointer;
            border-radius: 4px;
        }
        .box a {
            font-size: 13px;
            color: #666;
            text-decoration: none;
        }
        .box a:hover {
            color: #3498db;
        }
    </style>
</head>
<body>
    <div class="header">Test Track</div>
    <div class="box">
        <h2>Sign Up</h2>
        <form action="SignupServlet" method="post">
            <input type="text" name="username" placeholder="Username" required><br>
            <input type="email" name="email" placeholder="Email" required><br>
            <input type="password" name="password" placeholder="Password" required><br>
            <input type="password" name="confirm_password" placeholder="Confirm Password" required><br>
            <button type="submit">Create Account </button>
        </form>
        <p>Already have an account? <a href="login.jsp">Login here</a></p>
    </div>
</body>
</html>
