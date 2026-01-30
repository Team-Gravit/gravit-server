package gravit.code.user.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.config.UserDeleteMailProps;
import gravit.code.user.service.port.MailAuthCodeStore;
import gravit.code.user.support.MailAuthCodeGenerator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@RequiredArgsConstructor
@Service
public class DeletionAuthCodeManager {

    private final MailAuthCodeStore mailAuthCodeStore;
    private final UserDeleteMailProps props;

    public String generate(long userId) {
        String code = MailAuthCodeGenerator.createMailAuthCode(props.codeLength());
        mailAuthCodeStore.save(code, userId, props.expireTime());
        return code;
    }

    public long verify(String code) {
        Long userId = mailAuthCodeStore.consume(code);

        if (userId == null) {
            throw new RestApiException(CustomErrorCode.INVALID_MAIL_AUTH_CODE);
        }

        return userId;
    }

    // 보상 트랜잭션
    public void remove(String authCode) {
        try {
            mailAuthCodeStore.consume(authCode);
        } catch (Exception e){
            log.error("DeletionAuthCodeManager.remove : 인증 코드 삭제에 실패하였습니다.");
        }
    }
}
