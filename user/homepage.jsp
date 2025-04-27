<%@ page import="my_pack.AssessmentManager,my_pack.UserManager, my_pack.DBConnection, java.util.List, java.util.Map, java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User - Homepage</title>
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
        
        header {
            background-color: var(--white);
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            padding: 15px 0;
        }
        
        .header-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--primary-color);
        }
        
        nav {
            display: flex;
            gap: 20px;
        }
        
        nav a {
            color: var(--dark-gray);
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s ease;
        }
        
        nav a:hover {
            color: var(--primary-color);
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .search-container {
            margin: 30px 0;
        }
        
        .search-bar {
            position: relative;
            max-width: 800px;
            margin: 0 auto;
        }
        
        .search-input {
            width: 100%;
            padding: 12px 20px;
            border: 1px solid var(--medium-gray);
            border-radius: 5px;
            font-size: 16px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        
        .search-button {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--primary-color);
            cursor: pointer;
        }
        
        .section-title {
            color: var(--primary-color);
            margin-bottom: 20px;
            font-size: 1.8rem;
        }
        
        .card-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .card {
            background-color: var(--white);
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
            padding: 20px;
        }
        
        .card:hover {
            transform: translateY(-5px);
        }
        
        .card-content {
            padding: 0;
        }
        
        .card-title {
            font-size: 1.2rem;
            margin-bottom: 10px;
            color: var(--primary-color);
        }
        
        .card-description {
            color: var(--dark-gray);
            margin-bottom: 15px;
            font-size: 0.95rem;
        }
        
        .card-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 10px;
            border-top: 1px solid var(--medium-gray);
        }
        
        .card-duration {
            color: var(--dark-gray);
            font-size: 0.9rem;
        }
        
        .start-button {
            color: var(--primary-color);
            font-weight: 600;
            text-decoration: none;
            transition: color 0.3s ease;
        }
        
        .start-button:hover {
            color: var(--secondary-color);
        }
        
        .profile-section, .history-section, .recruiter-section, .about-section {
            background-color: var(--white);
            border-radius: 8px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .profile-header {
            font-size: 1.3rem;
            color: var(--primary-color);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .profile-info {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 15px;
        }
        
        .profile-item {
            margin-bottom: 10px;
        }
        
        .profile-label {
            font-weight: 600;
            color: var(--primary-color);
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
        }
        
        table tr:hover {
            background-color: var(--light-gray);
        }
        
        .status-completed {
            color: var(--success-color);
            font-weight: 600;
        }
        
        .status-pending {
            color: var(--warning-color);
            font-weight: 600;
        }
        
        .recruiter-button {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.3s ease;
            margin-top: 15px;
            text-decoration: none;
            display: inline-block;
        }
        
        .recruiter-button:hover {
            background-color: var(--secondary-color);
        }
        
        footer {
            background-color: var(--white);
            padding: 20px 0;
            text-align: center;
            margin-top: 50px;
            box-shadow: 0 -2px 5px rgba(0, 0, 0, 0.1);
        }
        
        .footer-text {
            color: var(--dark-gray);
            font-size: 0.9rem;
        }
        
        .divider {
            height: 1px;
            background-color: var(--medium-gray);
            margin: 30px 0;
        }
    </style>   
    <script>
        function scrollToSection(event) {
            event.preventDefault();
            const targetId = event.target.getAttribute('href');
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                window.scrollTo({
                    top: targetElement.offsetTop - 20,
                    behavior: 'smooth'
                });
            }
        }
    function handleRecruiterRequest(userName, userEmail) {
        const mailtoLink = `mailto:marwanam980@gmail.com?subject=Recruiter Application Request&body=Dear Admin,%0D%0A%0D%0AI would like to request recruiter access for my account.%0D%0A%0D%0AUser Details:%0D%0AName: ${userName}%0D%0AEmail: ${userEmail}%0D%0A%0D%0AThank you,%0D%0A${userName}`;
        window.open(`https://mail.google.com/mail/?view=cm&fs=1&to=marwanam980@gmail.com&su=Recruiter Application Request&body=${body}`)
        window.location.href = mailtoLink;
        alert("Your email client will open with a pre-filled request. Please send the email to complete your application.");
        return false;
    }
        document.addEventListener('DOMContentLoaded', function() {
            const navLinks = document.querySelectorAll('nav a');
            navLinks.forEach(link => {
                link.addEventListener('click', scrollToSection);
            });
            
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('search')) {
                const searchTerm = urlParams.get('search');
                if (searchTerm) {
                    window.scrollTo({
                        top: document.getElementById('assessments').offsetTop - 20,
                        behavior: 'smooth'
                    });
                }
            }
        });
    </script>
</head>
<body>
    <% 
        // Static user profile
       Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect("login.jsp"); // Redirect to login if user is not logged in
        return;
    }

    // Get user profile data
    UserManager userManager = new UserManager();
    Map<String, String> userProfile = userManager.getUserProfile(userId);

    String userName = userProfile.get("name");
    String userEmail = userProfile.get("email");
        
        // Get search query if exists
        String searchQuery = request.getParameter("search");
        boolean isSearching = searchQuery != null && !searchQuery.trim().isEmpty();
        
        // Get assessments from database
        AssessmentManager assessmentManager = new AssessmentManager();
        List<Map<String, String>> assessments = isSearching ? 
            assessmentManager.searchAssessmentsByName(searchQuery.trim()) : 
            assessmentManager.getAllAssessments();
        
        // Get test history from database
        List<Map<String, String>> testHistory = new java.util.ArrayList<>();
        String historyQuery = "SELECT t.title, tr.score, tr.status, tr.id " +
                             "FROM test_results tr " +
                             "JOIN tests t ON tr.test_id = t.id " +
                             "WHERE tr.user_id = ? " +
                             "ORDER BY tr.id DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(historyQuery)) {
            
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                java.util.Map<String, String> historyItem = new java.util.HashMap<>();
                historyItem.put("title", rs.getString("title"));
                historyItem.put("score", rs.getString("score"));
                historyItem.put("status", rs.getString("status"));
                historyItem.put("id", rs.getString("id"));
                testHistory.add(historyItem);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    %>
    
    <!-- Navbar -->
    <header>
        <div class="header-container">
            <div class="logo">Assessment System</div>
            <nav>
                <a href="#profile">Profile</a>
                <a href="#test-history">Test History</a>
                <a href="#recruiter">Become a Recruiter</a>
                <a href="#about">About</a>
            </nav>
        </div>
    </header>

    <!-- Main Content -->
    <div class="container">
        <!-- Search Bar -->
        <div class="search-container">
            <form action="homepage.jsp" method="get" class="search-bar">
                <input type="text" class="search-input" name="search" placeholder="Search Assessments..." 
                       value="<%= isSearching ? searchQuery : "" %>">
                <button type="submit" class="search-button">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="11" cy="11" r="8"></circle>
                        <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                    </svg>
                </button>
            </form>
        </div>

        <!-- Assessment Cards -->
        <section id="assessments">
            <h2 class="section-title">
                <%= isSearching ? "Search Results" : "Available Assessments" %>
                <% if (isSearching) { %>
                    <span class="search-results-term">for "<%= searchQuery %>"</span>
                <% } %>
            </h2>
            <div class="card-grid">
                <% if (assessments != null && !assessments.isEmpty()) { %>
                    <% for (Map<String, String> assessment : assessments) { %>
                        <div class="card">
                            <div class="card-content">
                                <h3 class="card-title"><%= assessment.get("name") %></h3>
                                <p class="card-description"><%= assessment.get("description") %></p>
                                <div class="card-footer">
                                    <span class="card-duration">30 Minutes</span>
                                    <a href="assessmentDetails.jsp?id=<%= assessment.get("id") %>" class="start-button">Start Test</a>
                                </div>
                            </div>
                        </div>
                    <% } %>
                <% } else { %>
                    <p>No assessments found <%= isSearching ? "matching your search" : "available at the moment" %>.</p>
                <% } %>
            </div>
        </section>

        <div class="divider"></div>

        <!-- Profile Section -->
        <section id="profile" class="profile-section">
            <h2 class="profile-header">Your Profile</h2>
            <div class="profile-info">
                <div class="profile-item">
                    <span class="profile-label">Name:</span> <%= userName %>
                </div>
                <div class="profile-item">
                    <span class="profile-label">Email:</span> <%= userEmail %>
                </div>
            </div>
        </section>

        <!-- Test History Section -->
        <section id="test-history" class="history-section">
            <h2 class="profile-header">Test History</h2>
            <table>
                <thead>
                    <tr>
                        <th>Test Title</th>
                        <th>Score</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                   <% for (Map<String, String> history : testHistory) { %>
                <tr>
                    <td><%= history.get("title") %></td>
                    <td><%= history.get("score") %></td>
                    <td><%= history.get("status") %></td>
                </tr>
            <% } %>
                </tbody>
            </table>
        </section>

        <div class="divider"></div>

        <!-- Become a Recruiter Section -->
<!-- Become a Recruiter Section -->
<section id="recruiter" class="recruiter-section">
    <h2 class="profile-header">Become a Recruiter</h2>
    <p>If you're interested in becoming a recruiter and accessing the platform's recruitment features, you can apply here:</p>
    <button class="recruiter-button" 
            onclick="return handleRecruiterRequest('<%= userName %>', '<%= userEmail %>')">
        Request to be a Recruiter
    </button>
</section>
        <!-- About Section -->
        <section id="about" class="about-section">
            <h2 class="profile-header">About the Platform</h2>
            <p>Our assessment platform provides high-quality tests designed to evaluate your technical skills across various domains. The platform is aimed at helping users prepare for their careers and track their progress over time.</p>
            <p style="margin-top: 15px;">Whether you're a beginner or an advanced developer, we have something for you!</p>
        </section>
    </div>

    <!-- Footer -->
    <footer>
        <div class="footer-text">© 2025 Assessment System. All rights reserved.</div>
    </footer>
</body>
</html>