import dal.DBContext;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.sql.*;
import java.util.*;

/** Chạy toàn bộ seed trên DB tạm, không reset hoặc ghi vào HRM_Project_DB. */
public class SeedDataIntegrationTest {
    private static int assertions;

    private static void check(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
        assertions++;
    }

    private static void execute(Connection conn, String sql) throws SQLException {
        try (Statement st = conn.createStatement()) { st.execute(sql); }
    }

    private static int count(Connection conn, String sql) throws SQLException {
        try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            rs.next(); return rs.getInt(1);
        }
    }

    private static Map<String, Integer> snapshot(Connection conn) throws SQLException {
        List<String> tables = new ArrayList<>();
        try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery("SELECT name FROM sys.tables ORDER BY name")) {
            while (rs.next()) tables.add(rs.getString(1));
        }
        Map<String, Integer> rows = new LinkedHashMap<>();
        for (String table : tables) rows.put(table, count(conn, "SELECT COUNT(*) FROM dbo.[" + table.replace("]", "]]") + "]"));
        return rows;
    }

    private static void seed(Connection conn, String seed) throws SQLException {
        int batchNumber = 0;
        for (String batch : seed.split("(?im)^GO\\s*$")) {
            batchNumber++;
            if (batch.isBlank()) continue;
            try { execute(conn, batch); }
            catch (SQLException e) { throw new SQLException("Seed batch " + batchNumber + " failed: " + e.getMessage(), e); }
        }
    }

    private static void scenario(String schema, String seed, boolean shifted) throws Exception {
        String database = "HRM_Seed_it_" + UUID.randomUUID().toString().replace("-", "");
        boolean created = false;
        try (Connection conn = DBContext.getInstance().getConnection()) {
            conn.setCatalog("master");
            try {
                execute(conn, "CREATE DATABASE [" + database + "]");
                created = true;
                conn.setCatalog(database);
                for (String batch : schema.split("(?im)^GO\\s*$")) if (!batch.isBlank()) execute(conn, batch);
                if (shifted) {
                    for (String table : List.of("Roles", "Job_Levels", "Departments", "Positions", "Users", "FlashcardDecks", "Learning_Materials", "Training_Classes")) {
                        execute(conn, "DBCC CHECKIDENT ('dbo." + table + "', RESEED, 100) WITH NO_INFOMSGS");
                    }
                }
                seed(conn, seed);
                Map<String,Integer> first = snapshot(conn);
                check(first.get("Roles") == 4 && first.get("Users") == 7 && first.get("Positions") == 19, "base seed counts");
                check(first.get("Learning_Materials") == 6 && first.get("Test_Content") == 8 && first.get("Test_Questions") == 110,
                        "six material banks plus culture/professional banks");
                check(first.get("FlashcardDecks") == 2 && first.get("Flashcards") == 25 && first.get("Video_Checkpoints") == 5, "flashcard and checkpoint counts");
                check(first.get("Training_Classes") == 1 && first.get("Class_Materials") == 6 && first.get("Class_Enrollments") == 1 && first.get("Learning_Progress") == 3,
                        "class association seed counts");
                seed(conn, seed);
                check(snapshot(conn).equals(first), "second seed does not add duplicates to any table");
                check(count(conn, "SELECT COUNT(*) FROM Users u JOIN Roles r ON r.role_id=u.role_id JOIN Departments d ON d.department_id=u.department_id "
                        + "JOIN Positions p ON p.position_id=u.position_id JOIN Job_Levels l ON l.level_id=u.level_id "
                        + "WHERE u.username='dev_fresher' AND r.role_name='EMPLOYEE' AND d.department_name=N'Phòng Kỹ Thuật (IT)' AND p.position_name=N'Java Developer' AND l.level_name='Fresher'") == 1,
                        "foreign keys resolve by natural keys even with shifted identities");
                check(count(conn, "SELECT COUNT(*) FROM Class_Enrollments e JOIN Users u ON u.user_id=e.user_id JOIN Training_Classes c ON c.class_id=e.class_id "
                        + "WHERE u.username='dev_fresher' AND c.class_code='CLS-IT-FRESHER-2026'") == 1, "class enrollment references intended user");
                execute(conn, "UPDATE Users SET full_name=N'Tên đã chỉnh sửa' WHERE username='dev_fresher'; "
                        + "UPDATE Learning_Progress SET status='COMPLETED'; UPDATE Class_Enrollments SET progress_percent=100");
                seed(conn, seed);
                check(snapshot(conn).equals(first), "third seed preserves every table count");
                check(count(conn, "SELECT COUNT(*) FROM Users WHERE username='dev_fresher' AND full_name=N'Tên đã chỉnh sửa'") == 1,
                        "existing edited user is preserved");
                check(count(conn, "SELECT COUNT(*) FROM Learning_Progress WHERE status<>'COMPLETED'") == 0
                        && count(conn, "SELECT COUNT(*) FROM Class_Enrollments WHERE progress_percent<>100") == 0, "existing progress is preserved");
                execute(conn, "DELETE FROM Flashcards WHERE card_id=(SELECT MIN(card_id) FROM Flashcards)");
                seed(conn, seed);
                check(snapshot(conn).equals(first), "partial seed repairs missing row without duplicating others");
                // Một lần chạy lỗi cũ có thể đã chèn trùng học liệu: không xóa dữ liệu,
                // và vẫn chọn cùng học liệu đầu tiên để tránh nhân đôi kho đề.
                execute(conn, "INSERT INTO Learning_Materials(title,description,material_type,scope_type,material_url,created_by) "
                        + "SELECT title,description,material_type,scope_type,material_url,created_by FROM Learning_Materials WHERE material_id=(SELECT MIN(material_id) FROM Learning_Materials)");
                Map<String,Integer> withDuplicate = snapshot(conn);
                seed(conn, seed);
                check(snapshot(conn).equals(withDuplicate), "pre-existing duplicate material does not create another bank");
            } finally {
                if (created && database.matches("HRM_Seed_it_[a-f0-9]{32}")) {
                    conn.setCatalog("master");
                    execute(conn, "ALTER DATABASE [" + database + "] SET SINGLE_USER WITH ROLLBACK IMMEDIATE");
                    execute(conn, "DROP DATABASE [" + database + "]");
                }
            }
        }
    }

    public static void main(String[] args) throws Exception {
        String schema = Files.readString(Path.of("database/schema/create_tables_sqlserver.sql"), StandardCharsets.UTF_8);
        schema = schema.substring(schema.indexOf("CREATE TABLE dbo.Roles"));
        String seed = Files.readString(Path.of("database/seed_data/seed_data_sqlserver.sql"), StandardCharsets.UTF_8)
                .replaceFirst("(?im)^USE HRM_Project_DB;\\s*$", "");
        scenario(schema, seed, false);
        scenario(schema, seed, true);
        System.out.println("PASS: " + assertions + " seed assertions on isolated databases (empty, repeated, partial, shifted IDs).");
    }
}
