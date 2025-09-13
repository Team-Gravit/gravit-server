package gravit.code.user.service.port;

public interface MailSender {
    void sendEmailWithMailAuthCodeAndHtml(String toEmail, String serviceEmail, String subject, String body);
}
