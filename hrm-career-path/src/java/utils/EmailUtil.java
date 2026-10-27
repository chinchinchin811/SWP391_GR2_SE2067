package utils;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

/**
 * Tiện ích gửi Email qua dịch vụ Google SMTP
 */
public class EmailUtil {

    // Địa chỉ Gmail gửi đi (Hệ thống)
    private static String SENDER_EMAIL = "TrongPDHE181640@fpt.edu.vn";

    // Mật khẩu ứng dụng Google (16 ký tự do người dùng cấp)
    private static final String SENDER_APP_PASSWORD = "scvyzkua rgrh rqmd".replace(" ", "");

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587"; // Cổng TLS

    /**
     * Cập nhật địa chỉ email gửi đi nếu cần thay đổi động
     */
    public static void setSenderEmail(String email) {
        if (email != null && !email.trim().isEmpty()) {
            SENDER_EMAIL = email.trim();
        }
    }

    public static String getSenderEmail() {
        return SENDER_EMAIL;
    }

    /**
     * Gửi email dạng HTML bất đồng bộ (chạy ngầm trên Thread riêng để không làm
     * đơ/chậm giao diện web)
     */
    public static void sendEmailAsync(String toEmail, String subject, String htmlContent) {
        new Thread(() -> {
            sendEmailSync(toEmail, subject, htmlContent);
        }).start();
    }

    /**
     * Gửi email dạng HTML đồng bộ
     */
    public static boolean sendEmailSync(String toEmail, String subject, String htmlContent) {
        if (toEmail == null || toEmail.trim().isEmpty()) {
            System.err.println("[EmailUtil] Lỗi: Địa chỉ email người nhận đang trống!");
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_APP_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL, "Hệ Thống Quản Trị Nhân Sự (HRM)",
                    StandardCharsets.UTF_8.name()));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail.trim()));
            message.setSubject(subject);
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println("[EmailUtil] Đã gửi email thành công tới: " + toEmail);
            return true;
        } catch (Exception e) {
            System.err.println("[EmailUtil] Gửi email thất bại tới: " + toEmail + " | Lỗi: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Mẫu Email: Chào mừng nhân sự mới & Cung cấp thông tin tài khoản đăng nhập
     */
    public static void sendNewAccountEmail(String toEmail, String fullName, String username, String password,
            String loginUrl) {
        String subject = "[Career Path Management] Chào mừng nhân sự mới - Thông tin tài khoản làm việc";
        String htmlContent = """
                <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: auto; padding: 28px; border: 1px solid #e2e8f0; border-radius: 12px; background-color: #ffffff; color: #1e293b; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
                    <div style="text-align: center; margin-bottom: 24px;">
                        <div style="display: inline-block; width: 48px; height: 48px; line-height: 48px; border-radius: 12px; background: #e0e7ff; color: #4338ca; font-size: 24px; margin-bottom: 10px;">

                        </div>
                        <h2 style="color: #4338ca; margin: 0; font-size: 22px;">Chào Mừng Đến Với Công Ty!</h2>
                        <p style="color: #64748b; font-size: 13.5px; margin-top: 4px;">Hệ thống Quản Trị Nhân Sự & Lộ Trình Nghề Nghiệp (HRM)</p>
                    </div>

                    <p style="font-size: 15px;">Xin chào <strong>%s</strong>,</p>
                    <p style="font-size: 14px; line-height: 1.6; color: #334155;">
                        Bộ phận Nhân sự (HR) đã khởi tạo tài khoản làm việc nội bộ cho bạn trên hệ thống HRM. Dưới đây là thông tin tài khoản đăng nhập chính thức:
                    </p>

                    <div style="background-color: #f8fafc; border: 1px solid #cbd5e1; border-left: 5px solid #4f46e5; padding: 16px 20px; border-radius: 8px; margin: 22px 0;">
                        <p style="margin: 8px 0; font-size: 14.5px;">
                            <strong>Tên đăng nhập (Username):</strong>
                            <span style="background: #e0e7ff; color: #3730a3; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-family: monospace; font-size: 15px;">%s</span>
                        </p>
                        <p style="margin: 8px 0; font-size: 14.5px;">
                            <strong>Mật khẩu khởi tạo:</strong>
                            <span style="background: #fee2e2; color: #991b1b; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-family: monospace; font-size: 15px;">%s</span>
                        </p>
                    </div>

                    <div style="background-color: #eff6ff; border: 1px solid #bfdbfe; border-radius: 6px; padding: 12px 16px; margin: 20px 0; font-size: 13px; color: #1e40af; line-height: 1.5;">
                         <strong>Lưu ý bảo mật:</strong> Đây là mật khẩu khởi tạo mặc định. Để đảm bảo an toàn dữ liệu, vui lòng đăng nhập và đổi lại mật khẩu cá nhân ngay trong lần đầu truy cập.
                    </div>

                    <div style="text-align: center; margin: 30px 0 15px 0;">
                        <a href="%s" style="background-color: #4f46e5; color: #ffffff; padding: 13px 32px; text-decoration: none; font-weight: 700; border-radius: 6px; display: inline-block; font-size: 14px; box-shadow: 0 4px 10px rgba(79, 70, 229, 0.35);">
                             Đăng Nhập Hệ Thống Ngay
                        </a>
                    </div>

                    <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 25px 0 15px 0;">
                    <p style="font-size: 12px; color: #94a3b8; text-align: center; margin: 0;">
                        Email này được gửi tự động từ Hệ thống Quản trị Nhân sự HRM. Vui lòng không phản hồi thư này.
                    </p>
                </div>
                """
                .formatted(fullName, username, password, loginUrl);

        sendEmailAsync(toEmail, subject, htmlContent);
    }
}
