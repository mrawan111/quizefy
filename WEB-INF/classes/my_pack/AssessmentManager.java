package my_pack;

import java.sql.*;
import java.util.*;

public class AssessmentManager {
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

 public boolean addAssessment(String name, String description, int userId) {
    String query = "INSERT INTO assessments (name, description, user_id) VALUES (?, ?, ?)";
    try (Connection conn = connect();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        ps.setString(1, name);
        ps.setString(2, description);
        ps.setInt(3, userId);
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
  public List<Map<String, String>> searchAdminAssessmentsByName(String searchTerm) {
    List<Map<String, String>> assessments = new ArrayList<>();
    String query = "SELECT a.id, a.name, a.description " +
                   "FROM assessments a " +
                   "JOIN users u ON a.user_id = u.id " +
                   "WHERE u.role = 'admin' AND a.name LIKE ?";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(query)) {
        
        pstmt.setString(1, "%" + searchTerm + "%");
        ResultSet rs = pstmt.executeQuery();
        
        while (rs.next()) {
            Map<String, String> assessment = new HashMap<>();
            assessment.put("id", rs.getString("id"));
            assessment.put("name", rs.getString("name"));
            assessment.put("description", rs.getString("description"));
            assessments.add(assessment);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    return assessments;
}

    public Map<String, String> getAssessmentById(int id) {
        Map<String, String> assessment = new HashMap<>();
        String query = "SELECT id, name, description FROM assessments WHERE id = ?";
        
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    assessment.put("id", rs.getString("id"));
                    assessment.put("name", rs.getString("name"));
                    assessment.put("description", rs.getString("description"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting assessment by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return assessment;
    }



    public List<Map<String, String>> getAssessmentQuestions(int assessmentId) {
        List<Map<String, String>> questions = new ArrayList<>();
        String query = "SELECT q.id, q.text, q.question_type, q.difficulty, t.title as test_title " +
                   "FROM questions q " +
                   "JOIN tests t ON q.test_id = t.id " +  // Fixed join
                   "WHERE t.assessment_id = ? " +         // Filter by assessment_id from tests
                   "ORDER BY t.id, q.id";
        
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, assessmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> question = new HashMap<>();
                    question.put("id", rs.getString("id"));
                    question.put("text", rs.getString("text"));
                    question.put("type", rs.getString("question_type"));
                    question.put("difficulty", rs.getString("difficulty"));
                    question.put("test_title", rs.getString("test_title"));
                    questions.add(question);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting assessment questions: " + e.getMessage());
            e.printStackTrace();
        }
        return questions;
    }
    public List<Map<String, String>> getTestsForAssessment(int assessmentId) {
    List<Map<String, String>> tests = new ArrayList<>();
    String query = "SELECT id, title, created_date, target_difficulty FROM tests WHERE assessment_id = ? ORDER BY id";
    
    try (Connection conn = connect();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        ps.setInt(1, assessmentId);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> test = new HashMap<>();
                test.put("id", rs.getString("id"));
                test.put("title", rs.getString("title"));
                test.put("created_date", rs.getString("created_date"));
                test.put("target_difficulty", rs.getString("target_difficulty"));
                tests.add(test);
            }
        }
    } catch (SQLException e) {
        System.err.println("Error getting tests for assessment: " + e.getMessage());
        e.printStackTrace();
    }
    return tests;
}
public List<Map<String, String>> getQuestionOptions(int questionId) {
    List<Map<String, String>> options = new ArrayList<>();
    String query = "SELECT id, option_text, is_correct FROM question_options WHERE question_id = ? ORDER BY id";
    
    try (Connection conn = connect();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        ps.setInt(1, questionId);
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            Map<String, String> option = new HashMap<>();
            option.put("id", rs.getString("id"));
            option.put("option_text", rs.getString("option_text"));
            option.put("is_correct", rs.getString("is_correct"));
            options.add(option);
        }
    } catch (SQLException e) {
        System.err.println("Error getting question options: " + e.getMessage());
        e.printStackTrace();
    }
    return options;
}

public List<Map<String, String>> getQuestionsByTestId(int testId) {
    List<Map<String, String>> questions = new ArrayList<>();
    String query = "SELECT id, text, question_type, difficulty, correct_answer FROM questions WHERE test_id = ? ORDER BY id";
    
    try (Connection conn = connect();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        ps.setInt(1, testId);
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            Map<String, String> question = new HashMap<>();
            question.put("id", rs.getString("id"));
            question.put("text", rs.getString("text"));
            question.put("type", rs.getString("question_type"));
            question.put("difficulty", rs.getString("difficulty"));
            question.put("correct_answer", rs.getString("correct_answer"));
            questions.add(question);
        }
    } catch (SQLException e) {
        System.err.println("Error getting questions by test ID: " + e.getMessage());
        e.printStackTrace();
    }
    return questions;
}public boolean checkAnswer(int questionId, String answer) {
    String query = "SELECT correct_answer FROM questions WHERE id = ?";
    try (Connection conn = connect();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        ps.setInt(1, questionId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            String correctAnswer = rs.getString("correct_answer");
            
            // تحقق من null قبل المقارنة
            if (correctAnswer != null && answer != null) {
                return correctAnswer.equalsIgnoreCase(answer);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}
public List<Map<String, String>> getAdminCreatedAssessments() {
    List<Map<String, String>> assessments = new ArrayList<>();
    String query = "SELECT a.id, a.name, a.description " +
                   "FROM assessments a " +
                   "JOIN users u ON a.user_id = u.id " +
                   "WHERE u.role = 'admin'";
    
    try (Connection conn = DBConnection.getConnection();
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
        e.printStackTrace();
    }
    
    return assessments;
}
// Add to AssessmentManager.java
public String generateShareableLink(int assessmentId) {
    // In a real application, you might want to:
    // 1. Generate a unique token
    // 2. Store it in the database with expiration
    // 3. Return a full URL
    
    // For simplicity, we'll just return the assessment ID for now
    return "assessment.jsp?id=" + assessmentId;
}
}