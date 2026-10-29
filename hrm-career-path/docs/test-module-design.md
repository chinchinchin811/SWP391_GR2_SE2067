# Module bài test và đánh giá

Module dùng Jakarta Servlet, JSP, JDBC và SQL Server. Đề thi Văn hóa và Chuyên
môn được lưu trong database, nạp qua migration/seed và chỉ đọc trên giao diện.
Các lớp nghiệp vụ có comment tiếng Việt mô tả hướng xử lý của từng hàm.
Seed mặc định cung cấp 10 câu Văn hóa và 10 câu Chuyên môn Java Backend.

## Bộ đề Học liệu

### Mentor giao bài theo lớp

- Mentor được xác định bằng `Training_Classes.mentor_id` còn hiệu lực trong database.
  Tài khoản EMPLOYEE được gán mentor có quyền xem kho và tạo đợt giao Học liệu
  cho lớp đó; HR vẫn bị loại khỏi module dù có dữ liệu phân công cũ.
- Từ trang chi tiết lớp, mentor mở **Đề Học liệu của lớp** hoặc **Tạo đợt giao
  bài cho lớp**. Form và kho đề cũng có bộ chọn lớp mentor phụ trách.
- Khi có `classId`, chỉ trả đề `learning` có `learning_material_id` nằm trong
  `Class_Materials` của đúng lớp; học liệu nguồn phải đang hoạt động và chưa xóa.
  Lớp chưa chọn học liệu hoặc chưa có đề tương ứng hiển thị danh sách trống.
- `Test_Templates.class_id` lưu phạm vi lớp, chỉ được dùng với loại `learning`.
  Server kiểm tra lại mentor, lớp, học liệu và người nhận trong transaction khi
  tạo/công bố/giao, kể cả khi sửa trực tiếp ID trong request.
- Mentor chỉ được giao cho học viên đã ghi danh của lớp, kể cả học viên thuộc
  phòng khác; không áp giới hạn phòng của Manager cho đợt giao theo lớp.
- Quyền quản lý đợt giao đi theo mentor hiện tại của lớp. Đợt giao theo lớp không
  xuất hiện cho người ngoài lớp; học viên đã được giao vẫn giữ quyền xem bài.
- Mentor đang phụ trách lớp chỉ thấy đề Học liệu của các lớp mình trong kho chung;
  mở kho của một lớp thì chỉ thấy đề đúng lớp đó. Quyền Chuyên môn riêng của
  Manager và Văn hóa của ADMIN được giữ lại ngoài ngữ cảnh lớp.
- Chỉ lớp `OPEN`/`IN_PROGRESS` được tạo đợt giao mới. Lớp đã hoàn thành vẫn có
  thể xem kho đề; lớp hủy/xóa không còn cấp quyền mentor.
- Schema lớp và đề Học liệu đã gộp trong `database/schema/create_tables_sqlserver.sql`.
  Với database hiện có, chỉ chạy khối từ `-- BEGIN TEST MODULE` đến
  `-- END TEST MODULE`; không chạy phần reset ở đầu file. Khối này có thể chạy lại,
  không đổi dữ liệu các đợt giao cũ.

- Loại `learning` (Học liệu) được Manager chọn khi tạo đợt giao, bên cạnh Chuyên môn.
- Sáu học liệu mẫu có sáu bộ đề riêng, mỗi bộ 15 câu một đáp án đúng. Nội dung
  dựa trên mô tả và checkpoint có trong hệ thống, chưa đối chiếu toàn bộ file gốc.
- `Test_Content.learning_material_id` liên kết tới học liệu; unique index ngăn tạo
  trùng bộ đề còn hoạt động cho cùng học liệu. Đề chung được Manager các phòng
  sử dụng; đề học liệu phòng ban chỉ Manager phòng đó quản lý.
- Đợt giao Học liệu luôn gắn với phòng Manager; kiểm tra quyền giao, lịch và
  chấm điểm giữ nguyên như Chuyên môn. ADMIN vẫn chỉ quản lý Văn hóa.
- Seed đề Học liệu nằm trực tiếp trong `database/seed_data/seed_data_sqlserver.sql`,
  ngay sau đề Chuyên môn Java Backend, giữa hai marker `BEGIN/END LEARNING TEST BANK SEED`.
  Học liệu nguồn được khởi tạo trước kho đề để liên kết đúng khi cài database mới.
  Với database hiện có, chạy khối `BEGIN/END TEST MODULE` trong file schema
  nếu chưa áp dụng, rồi chạy riêng khối seed Học liệu nói trên. Khối này có thể
  chạy lại, không reset database và không sửa câu hỏi của đề đã tồn tại.
- Schema và seed tổng đã bao gồm thay đổi cho database cài mới. Chỉnh nội dung
  câu hỏi trực tiếp trong khối seed Học liệu của `database/seed_data/seed_data_sqlserver.sql`.
  Học liệu mới cần bộ câu hỏi được biên soạn và bổ sung vào file seed này;
  hệ thống không tự suy diễn câu hỏi từ file upload.

## Quy tắc nghiệp vụ hiện tại

- Loại bài gồm `culture` (Văn hóa chung), `department` (Chuyên môn) và `learning` (Học liệu).
- ADMIN chỉ quản lý và giao đề Văn hóa. HR không truy cập Học liệu & Đào tạo,
  Flashcards hoặc Bài test & Đánh giá; giao diện HR chỉ giữ Quản trị Tổ chức và
  Quản trị Nhân sự. MANAGER quản lý Chuyên môn và Học liệu trong phạm vi phòng được giao.
- Bài đã công bố hiển thị trong toàn công ty. Đề nháp chỉ người có quyền quản lý
  nhìn thấy.
- MANAGER chỉ được giao cho tài khoản EMPLOYEE đang hoạt động trong đúng phòng
  mình quản lý; không thể giao cho cấp trên hoặc người ngoài phòng. ADMIN không
  có trang “Bài của tôi” và API cũng từ chối truy vấn này.
- Assignment chỉ được thu hồi khi còn `pending` bởi chính người đã giao hoặc
  người có vai trò cấp trên trong module (`ADMIN > MANAGER > EMPLOYEE`).
- Người chấm phải có vai trò cao hơn người làm; HR không tham gia luồng giao,
  làm hoặc chấm bài.
- Việc nhân viên chuyển phòng không làm mất bài đã được giao hoặc bài đã nộp.
- Người tạo đợt giao chọn đúng một đề đã sẵn sàng trong database theo hướng
  `culture` (Văn hóa), `department` (Chuyên môn) hoặc `learning` (Học liệu).
- Không có chức năng tạo, sửa hoặc xóa câu hỏi thủ công trên giao diện/API.
- Câu hỏi hỗ trợ `true_false`, `single` và `multiple`; số lựa chọn được lưu theo
  từng dòng nên có thể lớn hơn bốn. Câu `multiple` có thể có ba hoặc nhiều đáp
  án đúng và chỉ được tính đúng khi tập lựa chọn khớp hoàn toàn.
- Khi hết hạn, job tự đóng đợt giao nhưng giữ các assignment còn `pending` để
  bảng kết quả hiển thị trạng thái **Chưa làm**.
- Điểm dùng thang 0–10, tối đa hai chữ số thập phân. Một bài chỉ được nộp và
  chấm một lần.
- File bài làm tối đa 5 MiB, lưu trong database và chỉ tải qua endpoint kiểm tra
  quyền.

## Luồng sử dụng

1. ADMIN hoặc MANAGER mở **Tạo đợt giao bài**; mentor lớp có thể tạo đợt Học liệu cho lớp mình.
2. Chọn loại Văn hóa/Chuyên môn/Học liệu theo quyền, chọn đề trong database và lịch theo GMT+7.
3. Công bố đợt giao, chọn người nhận toàn công ty rồi giao bài.
4. Người nhận mở **Bài của tôi**, làm bài trong khoảng `[start_time, end_time)`.
5. Người quản lý mở kết quả, chấm điểm và ghi nhận xét.
6. Worker chạy mỗi phút để đóng đợt hết hạn; bài chưa làm vẫn nằm trong kết quả.

Thời gian lưu bằng UTC trong database, còn form và lịch hiển thị theo
`Asia/Ho_Chi_Minh` (GMT+7).

## Giao diện đã chốt

- Thanh điều hướng của module gồm **Tất cả đề**, **Sắp diễn ra**, **Bài của tôi**
  (ẩn với ADMIN) và **Lịch**.
- **Kho đề trong database** lọc theo vai trò: ADMIN chỉ thấy Văn hóa,
  MANAGER thấy Chuyên môn và Học liệu thuộc phạm vi của mình; HR không quản lý kho đề.
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
| `listener/TestReminderListener.java` | Đóng đề hết hạn, giữ nguyên bài chưa làm trong kết quả |
| `web/WEB-INF/views/tests/index.jsp` | Danh sách, lịch, tạo/giao/làm/chấm bài |
| `web/WEB-INF/views/tests/bank.jsp` | Kho đề Văn hóa/Chuyên môn chỉ đọc và đáp án quản lý |

## Route chính

| Phương thức | Action | Chức năng |
| --- | --- | --- |
| GET | `list`, `new`, `detail` | Danh sách, form tạo và chi tiết đợt giao |
| POST | `create`, `publish`, `close` | Tạo, công bố và đóng đợt giao bài |
| POST | `assign` | Giao cho danh sách người nhận, loại trừ ADMIN |
| GET | `mine`, `assignment`, `download` | Bài cá nhân, bài làm và file đính kèm |
| POST | `start`, `submit`, `submitQuiz`, `evaluate`, `revoke` | Làm, nộp, chấm và thu hồi |
| GET | `calendar` | Lịch theo khoảng ngày, tối đa 366 ngày |
| GET | `bank`, `bankDetail` | Danh sách và chi tiết kho đề database |

Mọi POST cần CSRF token. `userId`, vai trò, phòng quản lý, người tạo và người
chấm luôn được tải lại từ database; controller không tin các giá trị quyền gửi
từ trình duyệt.

## Database và migration

`database/seed_data/seed_data_sqlserver.sql` có thể chạy lại trên database đã có
schema: mọi nhóm seed chỉ thêm bản ghi còn thiếu theo tên/mã hoặc khóa nghiệp vụ.
Không cập nhật mật khẩu, thông tin người dùng, phân công mentor hay tiến độ đã có.
Khóa ngoại được tra theo tên/mã dữ liệu mẫu thay vì giả định ID bắt đầu từ 1.
Các bản ghi trùng từ lần chạy script cũ không bị tự xóa; script mới không tạo
thêm bản trùng. Bộ đề Học liệu chọn học liệu đầu tiên theo ID một cách nhất quán.

`test/SeedDataIntegrationTest.java` kiểm tra toàn bộ seed trên database tạm:
database rỗng, chạy lặp, dữ liệu thiếu một phần, ID đã dịch và dữ liệu đã chỉnh sửa.

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

`type='department'` của MANAGER gắn với phòng mình để kiểm soát quyền quản lý
ngân hàng. HR không tạo hoặc quản lý đề.

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
