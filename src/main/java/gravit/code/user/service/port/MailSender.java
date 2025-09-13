package gravit.code.user.service.port;

public interface MailSender {
    void sendEmailWithDeleteLink(String toEmail, String serviceEmail, String subject, String deleteLink);
}
