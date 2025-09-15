package gravit.code.user.service;

import gravit.code.global.consts.RedirectHostConst;
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
public class UserDeletionService {

    private final UserDeleteMailProps props;
    private final MailSender mailSender;
    private final UserRepository userRepository;
    private final MailAuthCodeStore mailAuthCodeStore;

    public void requestDeleteMailWithMailAuthCode(long userId, String dest) {
        User user = userRepository.findById(userId).orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        // local, prod 환경별로 다름
        String frontendConfirmUrl = makeDeleteLink(dest);

        // 메일 인증 코드 받아오기
        String mailAuthCode = MailAuthCodeGenerator.createMailAuthCode(props.codeLength());

        // redis 에 메일 인증 코드 키 + userId value 로 저장
        mailAuthCodeStore.save(mailAuthCode, userId, props.expireTime());

        // 실제 유저가 delete 할 수 있는 url 생성
        String deleteLink = UriComponentsBuilder
                .fromUriString(frontendConfirmUrl)
                .queryParam("mailAuthCode", mailAuthCode)
                .build(true)
                .toUriString();

        // 메일 전송
        String MAIL_SUBJECT = "[Gravit!] 회원 탈퇴 확인";
        mailSender.sendEmailWithDeleteLink(user.getEmail(), props.serviceEmail(), MAIL_SUBJECT, deleteLink);
    }

    private String makeDeleteLink(String dest) {
        String base = RedirectHostConst.DEST_BASE.get(dest);

        if (base == null || base.isBlank()) {
            throw new RestApiException(CustomErrorCode.DEST_NOT_VALID);
        }

        return base + "/user/me/delete/page";
    }

    @Transactional
    public void confirmDeleteByMailAuthCode(String mailAuthCode) {
        Long userId = mailAuthCodeStore.consume(mailAuthCode);

        // 메일 인증 코드에 해당하는 유저가 없다면 예외
        if (userId == null) {
            throw new RestApiException(CustomErrorCode.INVALID_MAIL_AUTH_CODE);
        }

        // 유저가 조회되면(Active 상태로 존재하면) soft delete
        userRepository.findById(userId)
                .ifPresent(user -> userRepository.deleteById(user.getId()));
    }
}
