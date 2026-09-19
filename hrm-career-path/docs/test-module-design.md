# Hướng triển khai module bài test

Module đã được triển khai bằng Servlet + JDBC + SQL Server, dùng đề tự do và bài nộp
văn bản/file, **không có ngân hàng câu hỏi**. Các hàm thực tế có comment tiếng Việt.
Phần chữ ký minh họa phía dưới giữ lại ý tưởng thiết kế; mã thực tế nhận `userId`
từ session, tải `TestActor` từ DB và dùng tham số Java thay cho các DTO minh họa.

## Chính sách đã chốt với người dùng

- ADMIN/HR tạo, giao và chấm bài `culture` cho người đang hoạt động trong công ty.
- MANAGER tạo, giao và chấm bài `department` của chính phòng mình đang quản lý.
  Cần đồng thời khớp Users.department_id và Departments.manager_id, phòng còn hoạt động.
- Mọi tài khoản hoạt động xem được đề culture đã công bố/đóng. Đề chuyên môn chỉ
  người cùng phòng được xem; ADMIN/HR không có quyền vượt phạm vi chuyên môn.
- Draft chỉ người quản lý trong phạm vi tương ứng được xem và không xuất hiện trên lịch.
- Bài nộp chỉ chủ bài/người quản lý đề được đọc. Nhân viên chuyển phòng mất quyền
  với bài chuyên môn cũ; người quản lý phòng cũ cũng không đọc/chấm bài của người đã chuyển.
  Dữ liệu và đánh giá cũ vẫn giữ lại trong database.
- Điểm 0–10, tối đa hai chữ số thập phân, nhận xét bắt buộc; không chấm lại/nộp lại.
- Cho nộp trong [start_time, end_time) khi đề published; có thể chấm bài đã nộp sau khi đóng đề.
- Thông báo trong ứng dụng nhắc bài pending trong 24 giờ trước lịch; chưa tích hợp email.
- File bài nộp tối đa 5 MiB, lưu VARBINARY trong DB và tải bằng endpoint kiểm tra quyền.

## Chạy module

1. Phần tạo bảng nằm trong file `database/schema/create_tables_sqlserver.sql`,
   gồm bảng HRM, module bài test và kho bộ đề/câu hỏi, không chứa dữ liệu mẫu.
   **Chạy toàn bộ file sẽ xóa và tạo lại HRM_Project_DB**, giống script gốc. Sau đó chạy `database/seed_data/seed_data_sqlserver.sql` một lần để nạp dữ liệu mẫu vào database mới.
   Với database đang có dữ liệu, chọn đúng `HRM_Project_DB` và chỉ chạy phần từ
   dòng `-- BEGIN TEST MODULE` đến cuối file. Phần này có thể chạy lại, không xóa dữ liệu.
2. NetBeans: Clean and Build, chạy bằng Tomcat 10.1 + JDK 17.
3. Mở mục **Bài test & Đánh giá** ở sidebar hoặc `/tests` dưới context của ứng dụng.
4. MANAGER/ADMIN/HR: Tạo đề → Lưu nháp → Công bố → Giao người nhận.
5. Nhân viên: Bài của tôi → Mở bài → Bắt đầu hoặc nộp trực tiếp trong giờ làm bài.
6. Người quản lý: Mở đề → Người được giao & Kết quả → Mở bài → Chấm điểm.

Thời gian lưu UTC, form/lịch hiển thị giờ Việt Nam. Job chạy mỗi phút, bắt đầu sau
30 giây khi deploy. Job dừng cùng ứng dụng; dữ liệu outbox giữ lại để retry khi lỗi.
Thông báo chưa phát mà lịch đã qua sẽ không được gửi muộn.

Kết nối mặc định giữ cấu hình hiện có trong DBContext. Có thể cấu hình Tomcat JVM
bằng `hrm.db.url`, `hrm.db.user`, `hrm.db.password` để dùng database khác.
DBContext nay trả connection riêng cho từng lần gọi, đóng bằng try-with-resources.

## File và đường dẫn thực tế

| Thành phần | File |
| --- | --- |
| Schema, CHECK, FK, UNIQUE | `database/schema/create_tables_sqlserver.sql` |
| Phân quyền | `src/java/policy/TestPolicy.java` |
| Nghiệp vụ và transaction | `src/java/service/TestService.java` |
| Query lọc phạm vi, outbox | `src/java/dal/TestDAO.java` |
| HTTP, session, CSRF, multipart | `src/java/controller/TestServlet.java` |
| Job nhắc lịch | `src/java/listener/TestReminderListener.java` |
| Giao diện được bảo vệ | `web/WEB-INF/views/tests/index.jsp` |

Ứng dụng dùng route Servlet `/tests` với `action`, phù hợp các module hiện có.
Mọi POST cần token `csrf`; GET không thay đổi trạng thái nghiệp vụ.

| Phương thức | action | Chức năng |
| --- | --- | --- |
| GET | list / new / detail | Danh sách, form tạo, chi tiết đề; list hỗ trợ scope=upcoming |
| POST | create / publish / close / archive | Tạo nháp, công bố, đóng, lưu trữ mềm |
| POST | assign | Giao cho các `assigneeId`, một transaction cho toàn bộ danh sách |
| GET | mine / assignment / download | Bài của tôi, bài nộp, tải file có kiểm tra quyền |
| POST | start / submit / evaluate / revoke | Bắt đầu, nộp, chấm, thu hồi mềm bài pending |
| GET | calendar | Lịch theo from/to; to không bao gồm ngày cuối, tối đa 366 ngày |
| GET / POST | notifications / read | Thông báo riêng và đánh dấu đã đọc |

Danh sách/lịch/bài được giao phân trang 20 dòng, dùng `page` bắt đầu từ 1.
Thu hồi assignment giữ UNIQUE(template_id, assignee_id): chưa hỗ trợ giao lại bài đã thu hồi.
Đề hiện hỗ trợ tạo, công bố, đóng và lưu trữ; chưa có sửa lịch/nội dung sau khi tạo.

## Chạy kiểm thử

Từ thư mục dự án, chạy `powershell -File test/run-tests.ps1`.
Có thể truyền `-TomcatHome` và `-AntHome` nếu đường dẫn cài đặt khác máy hiện tại.
Test dùng kết nối DB hiện tại để tạo database tên ngẫu nhiên `HRM_TestModule_it_*`
và `HRM_TestModule_http_*`, xóa đúng database của lần chạy trong finally.
Cần tài khoản SQL có quyền tạo/xóa database test; test không ghi fixture vào HRM_Project_DB.
HTTP test khởi động Tomcat riêng trên 127.0.0.1 với cổng ngẫu nhiên và dừng khi kết thúc.

Các nhóm kiểm thử: IDOR, draft, null department, quyền văn hóa/chuyên môn, đổi phòng,
khóa tài khoản, giao hàng loạt rollback, giao trùng, giờ nộp, file, chấm đồng thời,
rollback đánh giá, soft delete, outbox retry/chống trùng, CSRF, multipart và escape HTML.

## Áp dụng vào dự án hiện tại

- `controller`: Servlet nhận request, đọc `currentUser` từ session, gọi service và trả kết quả/JSP.
- `service`: xử lý nghiệp vụ, gọi policy và quản lý transaction JDBC.
- `policy`: kiểm tra quyền theo hành động và tài nguyên.
- `dal`: DAO dùng PreparedStatement; mọi truy vấn tài nguyên cần nhận phạm vi truy cập.
- `model`: bổ sung TestTemplate, TestAssignment, TestEvaluation.

Dự án đã có Users.department_id và Departments.manager_id. Cần xác minh phòng do người dùng
quản lý bằng dữ liệu này; không tin departmentId, assignedBy hoặc evaluatorId từ form.
Không dùng getDepartmentByManagerId trả một dòng nếu sau này cho phép quản lý nhiều phòng.
JDBC không có global scope ORM: nên gom truy vấn có giới hạn quyền vào DAO chuyên dụng,
không cung cấp hàm lấy bài theo ID không kiểm tra phạm vi cho controller gọi trực tiếp.

## Khung các hàm và comment hướng xử lý

```java
// TestPolicy — các hàm trả boolean, không ghi dữ liệu.

/**
 * Kiểm tra quyền xem ĐỀ, không phải quyền xem bài nộp.
 * 1. Từ chối tài khoản vô hiệu hóa và đề đã xóa mềm.
 * 2. Đề draft: chỉ người có quyền quản lý đề được xem.
 * 3. Đề published/closed: culture cho mọi người đã đăng nhập xem;
 *    department yêu cầu departmentId của người xem trùng phòng của đề.
 * 4. departmentId null không được coi là một phòng hợp lệ để so sánh.
 */
boolean canView(User actor, TestTemplate template);

/**
 * Kiểm tra quyền giao bài, độc lập với quyền xem đề.
 * 1. Yêu cầu vai trò leader/manager và quyền quản lý phòng ban từ database.
 * 2. Với đề department, người giao phải quản lý phòng của đề và thuộc phòng đó
 *    theo mô hình một phòng ban hiện tại; đề phải còn cho phép giao bài.
 * 3. Với đề culture, cần chính sách người được quản lý đề văn hóa riêng.
 * 4. Quyền xem culture không tự cấp quyền giao/chấm trên toàn công ty.
 * Service sẽ kiểm tra từng assignee trước khi tạo assignment.
 */
boolean canAssign(User actor, TestTemplate template);

/**
 * Kiểm tra quyền đọc một BÀI NỘP.
 * Cho phép chính assignee hoặc người có quyền đánh giá assignment này.
 * Không cho phép toàn bộ người cùng phòng đọc bài nộp của nhau.
 */
boolean canViewAssignment(User actor, TestAssignment assignment, TestTemplate template);

/**
 * Kiểm tra quyền chấm dựa trên assignment và đề đã tải từ database.
 * Yêu cầu vai trò người chấm, quyền quản lý đúng phạm vi và trạng thái submitted.
 * Không dùng riêng createdBy == actor.id để bỏ qua giới hạn phòng ban.
 * Với culture, chỉ người chấm được giao quyền theo chính sách đã xác định.
 * Việc leader chuyển phòng cần được kiểm tra lại bằng quyền hiện tại.
 */
boolean canEvaluate(User actor, TestAssignment assignment, TestTemplate template);

// TestService — controller phải đi qua lớp này trước khi đọc/ghi bài test.

/**
 * Tạo đề nháp từ dữ liệu đã validate.
 * 1. Tải lại vai trò/phòng ban hiện tại của actor, kiểm tra quyền tạo đề.
 * 2. Validate title, type và startTime < endTime.
 * 3. department: lấy phòng được phép từ server; culture: departmentId = null.
 * 4. Gán createdBy từ actor, status = draft; lưu và trả đề vừa tạo.
 * Không nhận createdBy/status tùy ý từ request.
 */
TestTemplate createTemplate(User actor, CreateTemplateRequest input);

/**
 * Công bố đề sau khi kiểm tra quyền quản lý và nội dung/lịch hợp lệ.
 * Chỉ chuyển draft -> published bằng UPDATE có điều kiện trạng thái cũ.
 * Nếu có người vừa sửa/đóng đề, báo xung đột thay vì ghi đè.
 */
void publishTemplate(User actor, int templateId);

/**
 * Liệt kê đề người dùng được phép xem, có phân trang.
 * Áp điều kiện culture hoặc cùng phòng trong SQL trước khi LIMIT/phân trang.
 * Lọc thêm is_deleted và trạng thái; không để draft lộ ra qua danh sách.
 * scope=upcoming lấy đề published có startTime > thời điểm hiện tại.
 */
List<TestTemplate> listTemplates(User actor, String scope, int page, int pageSize);

/**
 * Giao một đề cho nhiều người trong một transaction.
 * 1. Tải đề với phạm vi truy cập và gọi canAssign.
 * 2. Kiểm tra từng user còn hoạt động và thuộc phòng người giao quản lý;
 *    với department còn phải trùng phòng của đề.
 * 3. Loại ID lặp trong request; database có UNIQUE(template_id, assignee_id).
 * 4. Ghi assignedBy từ actor, status = pending; commit khi toàn bộ hợp lệ.
 * Nếu bất kỳ người nào không hợp lệ thì rollback toàn bộ lần giao.
 * Cần kiểm tra/khóa dữ liệu liên quan trong transaction để tránh đổi phòng
 * hoặc đóng đề giữa lúc kiểm tra và ghi.
 */
void assignTest(User actor, int templateId, List<Integer> assigneeIds);

/**
 * Lấy assignment của chính actor bằng WHERE assignee_id = actor.id.
 * Không cho truyền assigneeId khác qua URL để thay đổi người được truy vấn.
 * Join đề để kiểm tra xóa mềm và phạm vi phòng ban hiện tại.
 */
List<TestAssignment> getMyAssignments(User actor);

/**
 * Bắt đầu làm bài: kiểm tra actor là assignee và còn quyền truy cập đề.
 * Yêu cầu đề published, startTime <= now < endTime.
 * Chuyển pending -> in_progress bằng UPDATE có điều kiện trạng thái cũ.
 * Nếu đã in_progress thì có thể trả assignment hiện tại để tiếp tục làm.
 */
void startAssignment(User actor, int assignmentId);

/**
 * Nộp bài của chính actor trong thời gian được phép.
 * 1. Kiểm tra quyền sở hữu, phạm vi đề, trạng thái published và thời hạn.
 * 2. Validate nội dung/file; nếu dùng file, xác minh file thuộc người nộp,
 *    lưu mã file do server quản lý thay vì tin file_url bất kỳ từ request.
 * 3. Ghi nội dung, submittedAt bằng thời gian server và status = submitted.
 * 4. UPDATE chỉ khi trạng thái là pending/in_progress; kiểm tra số dòng đổi.
 * Mặc định không sửa bài đã nộp/đã chấm; mở lại bài cần nghiệp vụ riêng.
 */
void submitAssignment(User actor, int assignmentId, SubmissionRequest input);

/**
 * Chấm bài trong một transaction.
 * 1. Tải assignment và đề, kiểm tra canEvaluate trước khi đọc nội dung chấm.
 * 2. Validate điểm theo thang điểm đã thống nhất và độ dài nhận xét.
 * 3. INSERT evaluation với evaluatorId từ actor và evaluatedAt từ server.
 * 4. Chuyển submitted -> evaluated; nếu trạng thái đã đổi thì rollback.
 * UNIQUE(assignment_id) bảo đảm một kết quả nếu chưa hỗ trợ chấm lại.
 * Nếu cần chấm lại, bổ sung phiên bản/lịch sử thay vì ghi đè mất kết quả cũ.
 */
void evaluateAssignment(User actor, int assignmentId, EvaluationRequest input);

/**
 * Lấy lịch đề được phép xem trong khoảng [from, to).
 * Validate from < to và giới hạn độ dài khoảng truy vấn.
 * SQL tìm khoảng giao nhau: start_time < to AND end_time > from.
 * Dùng cùng điều kiện phân quyền/trạng thái với danh sách đề.
 * Chỉ trả thông tin lịch; không đưa bài nộp/nhận xét cá nhân vào lịch chung.
 */
List<TestTemplate> getCalendar(User actor, Instant from, Instant to);

/**
 * Đóng đề khi người có quyền yêu cầu: published -> closed.
 * Sau khi đóng, chặn giao/bắt đầu/nộp mới; vẫn cho chấm bài đã submitted
 * nếu người chấm còn quyền. Không xóa assignment và kết quả đã có.
 */
void closeTemplate(User actor, int templateId);

/**
 * Job nhắc lịch: tìm assignment pending của đề published sắp bắt đầu.
 * Kiểm tra lại tài khoản, quyền truy cập và đề chưa bị xóa/đóng.
 * Tạo thông báo có khóa chống trùng (assignmentId, loại nhắc, mốc lịch).
 * Dùng outbox và worker retry để gửi sau commit, tránh gửi lặp khi job chạy lại.
 * Chỉ tích hợp kênh email khi cấu hình gửi và yêu cầu nghiệp vụ đã rõ.
 */
void sendUpcomingReminders(Instant now);
```

## Ràng buộc database và các điểm cần thống nhất

- SQL Server dùng `VARCHAR` + `CHECK` cho type/status, không dùng cú pháp ENUM.
- CHECK: culture có department_id NULL; department phải có department_id.
- CHECK: start_time < end_time; FK cho đề, người được giao và người chấm.
- UNIQUE(template_id, assignee_id); UNIQUE(assignment_id) cho đánh giá một lần.
- Mọi thao tác ghi cần quyền ở server, transaction khi ghi nhiều bảng và cập nhật
  có điều kiện trạng thái để xử lý hai request đồng thời.
- Quyền culture, admin/HR, thang điểm và bài cũ khi chuyển phòng đã được chốt
  trong phần chính sách ở đầu tài liệu; các quyền ngoài phạm vi này bị từ chối.
- Các request ghi từ trình duyệt cần kiểm tra CSRF; file bài nộp tải qua endpoint
  kiểm tra quyền, không đặt vào thư mục công khai.
- Soft delete giữ lịch sử, nhưng vẫn phải loại dữ liệu đã xóa khỏi truy vấn thông thường.
- Nếu cache quyền, cần hết hạn/vô hiệu hóa khi đổi vai trò/phòng; thao tác ghi nên
  đọc quyền hiện tại để tránh dùng session/cache cũ.

## Kiểm thử khi triển khai

Kiểm tra truy cập chéo phòng bằng cách thay ID ở URL/body; nhân viên đọc/nộp bài
của người khác; draft lộ qua lịch; culture làm lộ bài nộp; leader chuyển phòng;
giao trùng; nộp ngoài giờ; hai request chấm đồng thời; rollback khi ghi kết quả lỗi.
