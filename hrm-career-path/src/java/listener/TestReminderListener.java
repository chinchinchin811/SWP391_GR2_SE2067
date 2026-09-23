package listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.time.Instant;
import java.util.concurrent.*;
import service.TestService;

/** Job nền đóng đề hết hạn, thu hồi bài pending và xử lý outbox nhắc lịch. */
@WebListener
public class TestReminderListener implements ServletContextListener {

    private ScheduledExecutorService executor;

    /**
     * Khởi động sau 30 giây, chạy mỗi phút; lỗi được log và thử lại ở chu kỳ
     * sau.
     */
    @Override
    public void contextInitialized(ServletContextEvent event) {
        executor = Executors.newSingleThreadScheduledExecutor(task -> {
            Thread thread = new Thread(task, "hrm-test-reminders");
            thread.setDaemon(true);
            return thread;
        });
        executor.scheduleWithFixedDelay(() -> {
            try {
                new TestService().sendUpcomingReminders(Instant.now());
            } catch (Exception e) {
                event.getServletContext().log("Không thể cập nhật lịch bài test; sẽ thử lại sau.", e);
            }
        }, 30, 60, TimeUnit.SECONDS);
    }

    /**
     * Dừng worker khi undeploy/redeploy, tránh giữ classloader của ứng dụng cũ.
     */
    @Override
    public void contextDestroyed(ServletContextEvent event) {
        if (executor != null) {
            executor.shutdownNow();
        }
    }
}
