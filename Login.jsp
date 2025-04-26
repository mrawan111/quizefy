<!DOCTYPE html>
<html>
<head>
    <title>Test Track - Login</title>
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
        .error-message {
            color: red;
            font-size: 14px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="header">Test Track</div>
    <div class="box">
        <h2>Login</h2>
        <form action="LoginServlet" method="post">
            <input type="text" name="username" placeholder="Username" required><br>
            <input type="password" name="password" placeholder="Password" required><br>
            <button type="submit">Login </button>
        </form>
        <p>Don't have an account? <a href="Signup.jsp">Sign up here</a></p>
    </div>
</body>
</html>
