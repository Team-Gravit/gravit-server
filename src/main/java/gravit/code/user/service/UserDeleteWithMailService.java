package gravit.code.user.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.config.UserDeleteMailProps;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import gravit.code.user.service.port.MailAuthCodeStore;
import gravit.code.user.service.port.MailSender;
import gravit.code.user.util.MailAuthCodeGenerator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.util.UriComponentsBuilder;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserDeleteWithMailService {

    private final UserDeleteMailProps props;
    private final MailSender mailSender;
    private final UserRepository userRepository;
    private final MailAuthCodeStore mailAuthCodeStore;

    public void requestDeleteMailWithMailAuthCode(long userId) {
        User user = userRepository.findById(userId).orElseThrow(()-> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        String mailAuthCode = MailAuthCodeGenerator.createMailAuthCode(props.codeLength());

        mailAuthCodeStore.save(mailAuthCode, userId, props.expireTime());

        log.info("mailAuthCode Save 완료: {}", mailAuthCode);

        String deleteLink = UriComponentsBuilder
                .fromUriString(props.frontendConfirmUrl())
                .queryParam("mailAuthCode", mailAuthCode)
                .build(true)
                .toUriString();
        log.info(" deleteLink: {}", deleteLink);

        log.info("메일센더 호출");
        mailSender.sendEmailWithMailAuthCodeAndHtml(user.getEmail(), props.serviceEmail(),"[Gravit] 회원 탈퇴 확인", deleteLink);
        
        log.info("메일 send 완료");
    }

    @Transactional
    public void confirmDeleteByMailAuthCode(String mailAuthCode) {
        Long userId = mailAuthCodeStore.consume(mailAuthCode);

        if (userId == null) {
            throw new RestApiException(CustomErrorCode.INVALID_MAIL_AUTH_CODE);
        }

        userRepository.findById(userId)
                .ifPresent(user -> userRepository.deleteById(user.getId()));
    }
}
