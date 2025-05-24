package my_pack;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
       private static final String URL = "jdbc:postgresql://turntable.proxy.rlwy.net:13001/railway";
    private static final String USER = "postgres";
    private static final String PASSWORD = "XpPVJptmTjhLhoaJwkDokjThDkkYuJPV";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("PostgreSQL JDBC Driver not found.", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
