package my_pack;

import java.sql.*;
import java.util.*;

public class AssessmentManager {
    private String url = "jdbc:postgresql://crossover.proxy.rlwy.net:29928/railway";
    private String username = "postgres";
    private String password = "TzRGIYmjwyLwlaZPPGoziHjOakANiumm";

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

    public List<Map<String, String>> getAllAssessments() {
        List<Map<String, String>> assessments = new ArrayList<>();
        String query = "SELECT id, name, description FROM assessments ORDER BY id";
        
        try (Connection conn = connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            
            while (rs.next()) {
                Map<String, String> assessment = new HashMap<>();
                assessment.put("id", rs.getString("id"));
                assessment.put("name", rs.getString("name"));
                assessment.put("description", rs.getString("description"));
                assessments.add(assessment);
            }
        } catch (SQLException e) {
            System.err.println("Error getting assessments: " + e.getMessage());
            e.printStackTrace();
        }
        return assessments;
    }

    public boolean addAssessment(String name, String description) {
        String query = "INSERT INTO assessments (name, description) VALUES (?, ?)";
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, name);
            ps.setString(2, description);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error adding assessment: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateAssessment(int id, String name, String description) {
        String query = "UPDATE assessments SET name = ?, description = ? WHERE id = ?";
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setInt(3, id);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error updating assessment: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteAssessment(int id) {
        String query = "DELETE FROM assessments WHERE id = ?";
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, id);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("Error deleting assessment: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public Map<String, String> getAssessmentById(int id) {
        String query = "SELECT id, name, description FROM assessments WHERE id = ?";
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, String> assessment = new HashMap<>();
                    assessment.put("id", rs.getString("id"));
                    assessment.put("name", rs.getString("name"));
                    assessment.put("description", rs.getString("description"));
                    return assessment;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting assessment by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    public List<Map<String, String>> searchAssessmentsByName(String searchTerm) {
    List<Map<String, String>> assessments = new ArrayList<>();
    String query = "SELECT id, name, description FROM assessments WHERE LOWER(name) LIKE LOWER(?) ORDER BY id";
    
    try (Connection conn = connect();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        ps.setString(1, "%" + searchTerm + "%");
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            Map<String, String> assessment = new HashMap<>();
            assessment.put("id", rs.getString("id"));
            assessment.put("name", rs.getString("name"));
            assessment.put("description", rs.getString("description"));
            assessments.add(assessment);
        }
    } catch (SQLException e) {
        System.err.println("Error searching assessments: " + e.getMessage());
        e.printStackTrace();
    }
    return assessments;
}
}