package my_pack;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserManager {
    private static final String url = "jdbc:postgresql://turntable.proxy.rlwy.net:13001/railway";
    private static final String username = "postgres";
    private static final String password = "XpPVJptmTjhLhoaJwkDokjThDkkYuJPV";


    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("PostgreSQL JDBC Driver not found.");
            e.printStackTrace();
        }
    }

    public Connection connect() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }

    public boolean registerUser(String name, String email, String password) {
        String query = "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, 'candidate')";
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, password);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error registering user: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean loginUser(String email, String password) {
        String query = "SELECT * FROM users WHERE email = ? AND password = ?";
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("Error logging in user: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public String getUserRole(String email, String password) {
        String query = "SELECT role FROM users WHERE email = ? AND password = ?";
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("role");
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting user role: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
 public static Map<String, String> getUserProfile(int userId) {
        Map<String, String> userProfile = new HashMap<>();
        String query = "SELECT name, email FROM users WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                userProfile.put("name", rs.getString("name"));
                userProfile.put("email", rs.getString("email"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return userProfile;
    }
    // In UserManager or similar class
public static List<Map<String, String>> getTestHistory(int userId) {
    List<Map<String, String>> testHistory = new ArrayList<>();
    String query = "SELECT title, score, status FROM test_results WHERE user_id = ?";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(query)) {

        pstmt.setInt(1, userId);
        ResultSet rs = pstmt.executeQuery();

        while (rs.next()) {
            Map<String, String> history = new HashMap<>();
            history.put("title", rs.getString("title"));
            history.put("score", rs.getString("score"));
            history.put("status", rs.getString("status"));
            testHistory.add(history);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    return testHistory;
}

    public String getUserName(String email, String password) {
        String query = "SELECT name FROM users WHERE email = ? AND password = ?";
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("name");
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting user name: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // New method to get user ID
    public Integer getUserId(String email, String password) {
        String query = "SELECT id FROM users WHERE email = ? AND password = ?";
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting user ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}
