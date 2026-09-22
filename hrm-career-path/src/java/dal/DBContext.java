package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    private static DBContext instance = new DBContext();

    private static final String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=HRM_Project_DB;encrypt=true;trustServerCertificate=true;";
    private static final String DB_USER = "sa";
    private static final String DB_PASSWORD = "123";
    private static final String DB_DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";

    public Connection getConnection() throws SQLException {
        try {
            Class.forName(DB_DRIVER);
            return DriverManager.getConnection(System.getProperty("hrm.db.url", DB_URL),
                    System.getProperty("hrm.db.user", DB_USER), System.getProperty("hrm.db.password", DB_PASSWORD));
        } catch (ClassNotFoundException e) {
            throw new SQLException("Khong tim thay SQL Server JDBC driver", e);
        }
    }

    public static DBContext getInstance() {
        return instance;
    }


    public void checkAndReconnect() {
        try (Connection conn = getConnection()) {
            if (!conn.isValid(3)) {
                throw new SQLException("Ket noi khong hop le");
            }
        } catch (SQLException e) {
            System.out.println("Loi khi ket noi lai: " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        System.out.println("Dang kiem tra ket noi database.");
        try (Connection conn = DBContext.getInstance().getConnection()) {
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
