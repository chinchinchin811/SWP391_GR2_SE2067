# Module bài test và đánh giá

Module dùng Jakarta Servlet, JSP, JDBC và SQL Server. Đề thi Văn hóa và Chuyên
môn được lưu trong database, nạp qua migration/seed và chỉ đọc trên giao diện.
Các lớp nghiệp vụ có comment tiếng Việt mô tả hướng xử lý của từng hàm.
Seed mặc định cung cấp 10 câu Văn hóa và 10 câu Chuyên môn Java Backend.

## Quy tắc nghiệp vụ hiện tại

- Loại bài gồm `culture` (Văn hóa chung) và `department` (Đánh giá chuyên môn).
- ADMIN/HR quản lý được cả hai loại. MANAGER quản lý đánh giá chuyên môn khi
  đang là quản lý một phòng hoạt động.
- Bài đã công bố hiển thị trong toàn công ty. Đề nháp chỉ người có quyền quản lý
  nhìn thấy.
- Có thể giao bài cho mọi tài khoản đang hoạt động trong công ty, ngoại trừ
  ADMIN. ADMIN không có trang “Bài của tôi” và API cũng từ chối truy vấn này.
- Việc nhân viên chuyển phòng không làm mất bài đã được giao hoặc bài đã nộp.
- Người tạo đợt giao chọn đúng một đề đã sẵn sàng trong database theo hướng
  `culture` (Văn hóa) hoặc `department` (Chuyên môn).
- Không có chức năng tạo, sửa hoặc xóa câu hỏi thủ công trên giao diện/API.
- Câu hỏi hỗ trợ `true_false`, `single` và `multiple`; số lựa chọn được lưu theo
  từng dòng nên có thể lớn hơn bốn. Câu `multiple` có thể có ba hoặc nhiều đáp
  án đúng và chỉ được tính đúng khi tập lựa chọn khớp hoàn toàn.
- Khi hết hạn, job tự đóng đợt giao và thu hồi mềm các assignment còn `pending`.
  Bài đã bắt đầu hoặc đã nộp vẫn được giữ để tiếp tục đối soát và chấm.
- Điểm dùng thang 0–10, tối đa hai chữ số thập phân. Một bài chỉ được nộp và
  chấm một lần.
- File bài làm tối đa 5 MiB, lưu trong database và chỉ tải qua endpoint kiểm tra
  quyền.

## Luồng sử dụng

1. ADMIN, HR hoặc MANAGER mở **Tạo đợt giao bài**.
2. Chọn hướng Văn hóa/Chuyên môn, chọn đề trong database và lịch theo GMT+7.
3. Công bố đợt giao, chọn người nhận toàn công ty rồi giao bài.
4. Người nhận mở **Bài của tôi**, làm bài trong khoảng `[start_time, end_time)`.
5. Người quản lý mở kết quả, chấm điểm và ghi nhận xét.
6. Worker chạy mỗi phút để đóng đợt hết hạn và thu hồi bài chưa bắt đầu.

Thời gian lưu bằng UTC trong database, còn form và lịch hiển thị theo
`Asia/Ho_Chi_Minh` (GMT+7).

## Giao diện đã chốt

- Thanh điều hướng của module gồm **Tất cả đề**, **Sắp diễn ra**, **Bài của tôi**
  (ẩn với ADMIN) và **Lịch**.
- **Kho đề trong database** hiển thị riêng hai nhóm Văn hóa và Chuyên môn.
- Sidebar không hiển thị “Bài được giao cho tôi” và “Thông báo nhắc lịch”.
- Trang kho đề chỉ đọc, không có form tạo/sửa/xóa câu hỏi hoặc xóa bộ đề.
- Dòng “Trang 1” chỉ xuất hiện khi thực sự có phân trang.
- Lỗi validation được hiển thị bằng popup rồi quay lại form trước đó.

## Phân lớp

| Thành phần | Trách nhiệm |
| --- | --- |
| `controller/TestServlet.java` | Session, CSRF, parse form, route và trả JSP |
| `service/TestService.java` | Validation, phân quyền nghiệp vụ và transaction |
| `policy/TestPolicy.java` | Quyền xem, quản lý, giao, làm và chấm bài |
| `dal/TestDAO.java` | PreparedStatement và giới hạn dữ liệu ngay trong SQL |
| `listener/TestReminderListener.java` | Đóng đề hết hạn, thu hồi bài pending và xử lý outbox |
| `web/WEB-INF/views/tests/index.jsp` | Danh sách, lịch, tạo/giao/làm/chấm bài |
| `web/WEB-INF/views/tests/bank.jsp` | Kho đề Văn hóa/Chuyên môn chỉ đọc và đáp án quản lý |

## Route chính

| Phương thức | Action | Chức năng |
| --- | --- | --- |
| GET | `list`, `new`, `detail` | Danh sách, form tạo và chi tiết đợt giao |
| POST | `create`, `publish`, `close`, `archive` | Tạo, công bố, đóng và lưu trữ mềm |
| POST | `assign` | Giao cho danh sách người nhận, loại trừ ADMIN |
| GET | `mine`, `assignment`, `download` | Bài cá nhân, bài làm và file đính kèm |
| POST | `start`, `submit`, `submitQuiz`, `evaluate`, `revoke` | Làm, nộp, chấm và thu hồi |
| GET | `calendar` | Lịch theo khoảng ngày, tối đa 366 ngày |
| GET | `bank`, `bankDetail` | Danh sách và chi tiết kho đề database |

Mọi POST cần CSRF token. `userId`, vai trò, phòng quản lý, người tạo và người
chấm luôn được tải lại từ database; controller không tin các giá trị quyền gửi
từ trình duyệt.

## Database và migration

`database/schema/create_tables_sqlserver.sql` chứa schema HRM và phần migration
bắt đầu tại `-- BEGIN TEST MODULE`. Chạy toàn bộ file sẽ tạo lại database. Với
database hiện có, chỉ chạy phần test module; migration này có thể chạy lặp và
không xóa dữ liệu.

Các cột quan trọng:

- `Test_Templates.default_content_id`: bộ đề mặc định của đợt giao.
- `Test_Content.is_deleted`: xóa mềm nội dung trong ngân hàng.
- `Test_Assignments.content_id`: tham chiếu nội dung đã giao.
- `Test_Assignments.quiz_score`: điểm trắc nghiệm tính ở server.
- `Test_Questions.question_type`: `true_false`, `single` hoặc `multiple`.
- `Test_Question_Options`: danh sách lựa chọn linh hoạt và cờ `is_correct`.
- `Test_Answer_Options`: mỗi lựa chọn người thi đã chọn là một dòng.

`type='department'` có thể có `department_id=NULL` khi ADMIN/HR tạo đánh giá
chuyên môn toàn công ty. MANAGER vẫn tạo nội dung chuyên môn gắn với phòng mình
để kiểm soát quyền quản lý ngân hàng.

## Kiểm thử

Chạy từ thư mục dự án:

```powershell
./test/run-tests.ps1
```

Test tạo database SQL Server tên ngẫu nhiên, chạy migration hai lần để kiểm tra
idempotence, khởi động Tomcat trên cổng ngẫu nhiên rồi xóa database trong
`finally`. Các nhóm kiểm tra gồm IDOR, CSRF, phạm vi toàn công ty, loại trừ
ADMIN, câu đúng/sai, câu ba đáp án đúng, câu hơn bốn lựa chọn, không lộ đáp án,
transaction, hết hạn, soft delete, upload/download và escape HTML.
