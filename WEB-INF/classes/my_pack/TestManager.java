package my_pack;
import java.sql.*;
import java.util.*;

public class TestManager {
    private String url = "jdbc:postgresql://crossover.proxy.rlwy.net:29928/railway";
    private String username = "postgres";
    private String password = "TzRGIYmjwyLwlaZPPGoziHjOakANiumm";

    public Connection connect() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }

    public List<Map<String, String>> getAllTests() {
        List<Map<String, String>> list = new ArrayList<>();
        try (Connection conn = connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM tests")) {
            while (rs.next()) {
                Map<String, String> test = new HashMap<>();
                test.put("id", rs.getString("id"));
                test.put("title", rs.getString("title"));
                test.put("description", rs.getString("description"));
                list.add(test);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void addTest(String title, String description) {
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement("INSERT INTO tests (title, description) VALUES (?, ?)")) {
            ps.setString(1, title);
            ps.setString(2, description);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateTest(int id, String title, String description) {
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement("UPDATE tests SET title = ?, description = ? WHERE id = ?")) {
            ps.setString(1, title);
            ps.setString(2, description);
            ps.setInt(3, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteTest(int id) {
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM tests WHERE id = ?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Map<String, String> getTestById(int id) {
        Map<String, String> test = null;
        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM tests WHERE id = ?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                test = new HashMap<>();
                test.put("id", rs.getString("id"));
                test.put("title", rs.getString("title"));
                test.put("description", rs.getString("description"));
            }
            rs.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return test;
    }
}
