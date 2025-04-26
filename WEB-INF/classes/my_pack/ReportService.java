package my_pack;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReportService {
    public static List<TestResult> getFilteredResults(int assessmentId, int userId, String dateRange) {
        List<TestResult> results = new ArrayList<>();
        String sql = buildQuery(assessmentId, userId, dateRange);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = buildStatement(conn, sql, assessmentId, userId);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                TestResult result = new TestResult();
                result.setId(rs.getInt("result_id"));
                result.setUserName(rs.getString("user_name"));
                result.setAssessmentName(rs.getString("assessment_name"));
                result.setCreatedDate(rs.getDate("created_date"));
                result.setScore(rs.getDouble("score"));
                result.setStatus(rs.getString("status"));
                results.add(result);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return results;
    }

    public static ChartData getChartData(int assessmentId, int userId, String dateRange) {
        ChartData chartData = new ChartData();
        String sql = "SELECT COUNT(*) as count, " +
                     "SUM(CASE WHEN score >= 80 THEN 1 ELSE 0 END) as high, " +
                     "SUM(CASE WHEN score >= 50 AND score < 80 THEN 1 ELSE 0 END) as medium, " +
                     "SUM(CASE WHEN score < 50 THEN 1 ELSE 0 END) as low " +
                     "FROM test_results tr JOIN tests t ON tr.test_id = t.id " +
                     buildWhereClause(assessmentId, userId, dateRange);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = buildStatement(conn, sql, assessmentId, userId);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                chartData.setTotal(rs.getInt("count"));
                chartData.setHighScore(rs.getInt("high"));
                chartData.setMediumScore(rs.getInt("medium"));
                chartData.setLowScore(rs.getInt("low"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return chartData;
    }

    private static String buildQuery(int assessmentId, int userId, String dateRange) {
        return "SELECT tr.id as result_id, u.name as user_name, a.name as assessment_name, " +
               "t.created_date, tr.score, tr.status " +
               "FROM test_results tr " +
               "JOIN users u ON tr.user_id = u.id " +
               "JOIN assessments a ON tr.assessment_id = a.id " +
               "JOIN tests t ON tr.test_id = t.id " +
               buildWhereClause(assessmentId, userId, dateRange) +
               " ORDER BY t.created_date DESC";
    }

    private static String buildWhereClause(int assessmentId, int userId, String dateRange) {
        StringBuilder where = new StringBuilder(" WHERE 1=1");
        if (assessmentId > 0) where.append(" AND tr.assessment_id = ?");
        if (userId > 0) where.append(" AND tr.user_id = ?");
        if (dateRange != null) {
            switch(dateRange) {
                case "week":
                    where.append(" AND t.created_date >= CURRENT_DATE - INTERVAL '1 week'");
                    break;
                case "month":
                    where.append(" AND t.created_date >= CURRENT_DATE - INTERVAL '1 month'");
                    break;
            }
        }
        return where.toString();
    }

    private static PreparedStatement buildStatement(Connection conn, String sql, 
                                                 int assessmentId, int userId) 
                                                 throws SQLException {
        PreparedStatement stmt = conn.prepareStatement(sql);
        int paramIndex = 1;
        if (assessmentId > 0) stmt.setInt(paramIndex++, assessmentId);
        if (userId > 0) stmt.setInt(paramIndex++, userId);
        return stmt;
    }
    public static TestResult getTestResultById(int resultId) {
    String sql = "SELECT tr.id, u.name as user_name, a.name as assessment_name, " +
                 "t.created_date, tr.score, tr.status " +
                 "FROM test_results tr " +
                 "JOIN users u ON tr.user_id = u.id " +
                 "JOIN assessments a ON tr.assessment_id = a.id " +
                 "JOIN tests t ON tr.test_id = t.id " +
                 "WHERE tr.id = ?";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setInt(1, resultId);
        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                TestResult result = new TestResult();
                result.setId(rs.getInt("id"));
                result.setUserName(rs.getString("user_name"));
                result.setAssessmentName(rs.getString("assessment_name"));
                result.setCreatedDate(rs.getDate("created_date"));
                result.setScore(rs.getDouble("score"));
                result.setStatus(rs.getString("status"));
                return result;
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return null;
}

public static List<Map<String, Object>> getPerformanceTrend(int assessmentId, int userId, String period) {
    List<Map<String, Object>> trendData = new ArrayList<>();
    String sql = "SELECT DATE_TRUNC('week', t.created_date) as week, " +
                 "AVG(tr.score) as avg_score " +
                 "FROM test_results tr " +
                 "JOIN tests t ON tr.test_id = t.id " +
                 "WHERE tr.score IS NOT NULL " +
                 (assessmentId > 0 ? " AND tr.assessment_id = ?" : "") +
                 (userId > 0 ? " AND tr.user_id = ?" : "") +
                 " GROUP BY week ORDER BY week";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        int paramIndex = 1;
        if (assessmentId > 0) stmt.setInt(paramIndex++, assessmentId);
        if (userId > 0) stmt.setInt(paramIndex++, userId);
        
        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> dataPoint = new HashMap<>();
                dataPoint.put("week", rs.getDate("week"));
                dataPoint.put("avg_score", rs.getDouble("avg_score"));
                trendData.add(dataPoint);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return trendData;
}
public static List<Assessment> getAllAssessments() {
    List<Assessment> assessments = new ArrayList<>();
    String sql = "SELECT id, name FROM assessments";

    try (Connection conn = DBConnection.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
        
        while (rs.next()) {
            Assessment a = new Assessment();
            a.setId(rs.getInt("id"));
            a.setName(rs.getString("name"));
            assessments.add(a);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return assessments;
}

public static List<User> getAllUsers() {
    List<User> users = new ArrayList<>();
    String sql = "SELECT id, name FROM users";

    try (Connection conn = DBConnection.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
        
        while (rs.next()) {
            User u = new User();
            u.setId(rs.getInt("id"));
            u.setName(rs.getString("name"));
            users.add(u);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return users;
}

}