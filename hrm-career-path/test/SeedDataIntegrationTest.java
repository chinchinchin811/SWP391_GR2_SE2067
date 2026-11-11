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
        try (Statement st = conn.createStatement()) {
            boolean hasResults = st.execute(sql);
            while (hasResults || st.getUpdateCount() != -1) {
                hasResults = st.getMoreResults();
            }
        }
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

    private static void scenario(String schema, String seed) throws Exception {
        String database = "HRM_Seed_it_" + UUID.randomUUID().toString().replace("-", "");
        boolean created = false;
        try (Connection conn = DBContext.getInstance().getConnection()) {
            conn.setCatalog("master");
            try {
                execute(conn, "CREATE DATABASE [" + database + "]");
                created = true;
                conn.setCatalog(database);
                for (String batch : schema.split("(?im)^GO\\s*$")) if (!batch.isBlank()) execute(conn, batch);
                seed(conn, seed);
                Map<String,Integer> first = snapshot(conn);
                check(first.get("Roles") == 4 && first.get("Users") >= 7 && first.get("Positions") == 19, "base seed counts");
                check(first.get("Learning_Materials") == 3 && first.get("Test_Content") == 1 && first.get("Test_Questions") == 10,
                        "seed contains training materials and only the professional test set");
                check(first.get("FlashcardDecks") == 2 && first.get("Flashcards") == 25 && first.get("Video_Checkpoints") == 3, "flashcard and checkpoint counts");
                check(first.get("Training_Classes") == 1 && first.get("Class_Materials") == 3 && first.get("Class_Enrollments") == 1 && first.get("Learning_Progress") == 3,
                        "class association seed counts");
                check(count(conn, "SELECT COUNT(*) FROM Test_Content WHERE type <> 'department'") == 0,
                        "seed does not include learning or culture test sets");
                check(count(conn, "SELECT COUNT(*) FROM Class_Enrollments e JOIN Users u ON u.user_id=e.user_id JOIN Training_Classes c ON c.class_id=e.class_id "
                        + "WHERE u.username='dev_fresher' AND c.class_code='CLS-IT-FRESHER-2026'") == 1, "class enrollment references intended user");
                verifyLearningSetRemoval(conn, first);
            } finally {
                if (created && database.matches("HRM_Seed_it_[a-f0-9]{32}")) {
                    conn.setCatalog("master");
                    execute(conn, "ALTER DATABASE [" + database + "] SET SINGLE_USER WITH ROLLBACK IMMEDIATE");
                    execute(conn, "DROP DATABASE [" + database + "]");
                }
            }
        }
    }

    private static void verifyLearningSetRemoval(Connection conn, Map<String, Integer> original) throws Exception {
        execute(conn, """
                ALTER TABLE dbo.Test_Content DROP CONSTRAINT CK_Content_Scope;
                ALTER TABLE dbo.Test_Templates DROP CONSTRAINT CK_Test_Type;
                ALTER TABLE dbo.Test_Content ADD learning_material_id INT NULL
                    CONSTRAINT FK_Test_Content_Learning_Material REFERENCES dbo.Learning_Materials(material_id);
                ALTER TABLE dbo.Test_Templates ADD class_id INT NULL
                    CONSTRAINT FK_Test_Template_Class REFERENCES dbo.Training_Classes(class_id);
                """);
        execute(conn, """
                INSERT INTO dbo.Test_Content(title,prompt,kind,type,department_id,created_by,status,learning_material_id)
                VALUES (N'Đề học liệu cũ',N'Mô tả','quiz','learning',1,3,'ready',1);
                DECLARE @content INT = SCOPE_IDENTITY();
                INSERT INTO dbo.Test_Questions(content_id,prompt,question_type) VALUES (@content,N'Câu hỏi','single');
                DECLARE @question INT = SCOPE_IDENTITY();
                INSERT INTO dbo.Test_Question_Options(question_id,option_text,is_correct,display_order)
                VALUES (@question,N'Đáp án',1,1);
                DECLARE @option INT = SCOPE_IDENTITY();
                INSERT INTO dbo.Test_Templates(title,description,type,department_id,created_by,status,start_time,end_time,default_content_id,class_id)
                VALUES (N'Đợt giao cũ',N'Mô tả','learning',1,3,'published','2026-01-01','2026-01-02',@content,1);
                DECLARE @template INT = SCOPE_IDENTITY();
                INSERT INTO dbo.Test_Assignments(test_template_id,assignee_id,assigned_by,content_id)
                VALUES (@template,4,3,@content);
                DECLARE @assignment INT = SCOPE_IDENTITY();
                INSERT INTO dbo.Test_Answer_Options(assignment_id,question_id,option_id)
                VALUES (@assignment,@question,@option);
                INSERT INTO dbo.Test_Evaluations(test_assignment_id,evaluator_id,score,comment)
                VALUES (@assignment,3,10,N'Đã chấm');
                """);
        String migration = Files.readString(Path.of("database/schema/remove_learning_test_sets.sql"), StandardCharsets.UTF_8);
        execute(conn, migration);
        execute(conn, migration);
        Map<String, Integer> remaining = snapshot(conn);
        check(remaining.equals(original), "unexpected row counts after migration: " + remaining + " (expected " + original + ")");
        check(count(conn, "SELECT COUNT(*) FROM sys.columns WHERE name IN ('learning_material_id','class_id') "
                + "AND object_id IN (OBJECT_ID('dbo.Test_Content'), OBJECT_ID('dbo.Test_Templates'))") == 0,
                "migration drops legacy material and class links");
    }

    public static void main(String[] args) throws Exception {
        String schema = Files.readString(Path.of("database/schema/create_tables_sqlserver.sql"), StandardCharsets.UTF_8);
        schema = schema.substring(schema.indexOf("CREATE TABLE dbo.Roles"));
        String seed = Files.readString(Path.of("database/seed_data/seed_data_sqlserver.sql"), StandardCharsets.UTF_8)
                .replaceFirst("(?im)^USE HRM_Project_DB;\\s*$", "");
        scenario(schema, seed);
        System.out.println("PASS: " + assertions + " seed assertions on an isolated database.");
    }
}
