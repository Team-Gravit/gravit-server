package gravit.code.user.infrastructure.mail;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.service.port.MailSender;
import gravit.code.user.util.MailHtmlRenderer;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import static java.nio.charset.StandardCharsets.UTF_8;

@Service
@RequiredArgsConstructor
@Slf4j
public class StmpMailSender implements MailSender {
    private final JavaMailSender mailSender;

    @Override
    public void sendEmailWithDeleteLink(String toEmail, String serviceEmail, String subject, String deleteLink) {
        try{
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message,true, UTF_8.name());
            String html = MailHtmlRenderer.buildAccountDeletionEmail(deleteLink);

            helper.setTo(toEmail);
            helper.setSubject(subject);
            helper.setFrom(serviceEmail);
            helper.setText(html, true);

            mailSender.send(message);
        } catch (MessagingException e) {
            throw new RestApiException(CustomErrorCode.MAIL_SEND_ERROR);
        }
    }
}
