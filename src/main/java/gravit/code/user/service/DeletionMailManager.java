package gravit.code.user.service;

import gravit.code.user.config.UserDeleteMailProps;
import gravit.code.user.service.port.MailSender;
import gravit.code.user.support.UserDeletionUrlBuilder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class DeletionMailManager {

    private final MailSender mailSender;
    private final UserDeletionUrlBuilder urlBuilder;
    private final UserDeleteMailProps props;

    private static final String MAIL_SUBJECT = "[Gravit!] 회원 탈퇴 확인";

    public void requestDeletion(String email, String dest, String authCode) {
        String deleteLink = urlBuilder.buildConfirmationUrl(dest, authCode);

        mailSender.sendEmailWithDeleteLink(
                email,
                props.serviceEmail(),
                MAIL_SUBJECT,
                deleteLink
        );
    }
}
