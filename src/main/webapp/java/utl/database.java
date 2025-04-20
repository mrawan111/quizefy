package main.webapp.java.utl;
import java.sql.Connection;
import java.sql.DriverManager;

public class database {
    private static final String URL = "jdbc:postgresql://nozomi.proxy.rlwy.net:45540/railway";
    private static final String USERNAME = "postgres";
    private static final String PASSWORD = "CdRsSkEKFtXhtZIJlEiSLjxUusKOnEMI";

    public static Connection getConnection() throws Exception {
        Class.forName("org.postgresql.Driver");
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}
