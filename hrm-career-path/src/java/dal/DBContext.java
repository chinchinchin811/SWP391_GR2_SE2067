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
            throw new SQLException("Không tìm thấy SQL Server JDBC driver", e);
        }
    }

    public static DBContext getInstance() {
        return instance;
    }


    public void checkAndReconnect() {
        try (Connection conn = getConnection()) {
            if (!conn.isValid(3)) {
                throw new SQLException("Kết nối không hợp lệ");
            }
        } catch (SQLException e) {
            System.out.println("Lỗi khi kết nối lại: " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        System.out.println("Đang kiểm tra kết nối database.");
        try (Connection conn = DBContext.getInstance().getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("Kết nối cơ sở dữ liệu thành công!");
                System.out.println("Catalog hiện tại: " + conn.getCatalog());
            } else {
                System.out.println("Kết nối thất bại!");
            }
        } catch (SQLException e) {
            System.err.println("Lỗi kết nối: " + e.getMessage());
        }
    }
}
