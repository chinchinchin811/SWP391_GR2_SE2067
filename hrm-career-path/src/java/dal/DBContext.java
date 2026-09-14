package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    private static DBContext instance = new DBContext();
    private Connection connection;

    private static final String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=HRM_Project_DB;encrypt=true;trustServerCertificate=true;";
    private static final String DB_USER = "sa";
    private static final String DB_PASSWORD = "123";
    private static final String DB_DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";

    public Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            reconnect();
        }
        return connection;
    }

    public static DBContext getInstance() {
        return instance;
    }

    private void reconnect() throws SQLException {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();  
            }
            Class.forName(DB_DRIVER);  
            connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD); 
        } catch (SQLException | ClassNotFoundException e) {
            throw new SQLException("Ket noi lai co so du lieu khong thanh cong: " + e.getMessage());
        }
    }

    public void checkAndReconnect() {
        try {
            if (connection == null || connection.isClosed()) {
                reconnect(); 
            }
        } catch (SQLException e) {
            System.out.println("Loi khi ket noi lai: " + e.getMessage());
        }
    }

    /**
     * Ham main de chay test truc tiep ket noi database.
     * Nhan Shift + F6 (Run File) trong NetBeans de chay thu.
     */
    public static void main(String[] args) {
        System.out.println("Dang kiem tra ket noi database.");
        try {
            Connection conn = DBContext.getInstance().getConnection();
            if (conn != null && !conn.isClosed()) {
                System.out.println("Ket noi co so du lieu thanh cong!");
                System.out.println("Catalog hien tai: " + conn.getCatalog());
            } else {
                System.out.println("Ket noi that bai!");
            }
        } catch (SQLException e) {
            System.err.println("Loi ket noi: " + e.getMessage());
        }
    }
}