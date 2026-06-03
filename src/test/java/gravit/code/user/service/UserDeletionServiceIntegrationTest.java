package gravit.code.user.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.service.port.MailAuthCodeStore;
import gravit.code.user.service.port.MailSender;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import static gravit.code.global.exception.domain.CustomErrorCode.DEST_NOT_VALID;
import static gravit.code.global.exception.domain.CustomErrorCode.INVALID_MAIL_AUTH_CODE;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class UserDeletionServiceIntegrationTest {

    @Autowired
    private UserDeletionService userDeletionService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private MailAuthCodeStore mailAuthCodeStore;

    @MockitoBean
    private MailSender mailSender;

    @Nested
    @DisplayName("회원 탈퇴 메일을 요청할 때")
    class RequestDeleteMail {

        @Test
        void 유효한_유저와_dest이면_메일을_발송한다() {
            // given
            User user = userFixture.일반_유저(1);

            // when
            userDeletionService.requestDeleteMailWithMailAuthCode(user.getId(), "local");

            // then
            verify(mailSender, times(1)).sendEmailWithDeleteLink(any(), any(), any(), any());
        }

        @Test
        void 존재하지_않는_유저이면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userDeletionService.requestDeleteMailWithMailAuthCode(nonExistentUserId, "local"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }

        @Test
        void 유효하지_않은_dest이면_예외를_던진다() {
            // given
            User user = userFixture.일반_유저(1);

            // when & then
            assertThatThrownBy(() -> userDeletionService.requestDeleteMailWithMailAuthCode(user.getId(), "invalid-dest"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(DEST_NOT_VALID);
        }
    }

    @Nested
    @DisplayName("메일 인증 코드로 회원 탈퇴를 확인할 때")
    class ConfirmDeleteByMailAuthCode {

        @Test
        void 유효한_인증코드이면_회원을_탈퇴_처리한다() {
            // given
            User user = userFixture.일반_유저(1);
            String authCode = "validauthcode123";
            mailAuthCodeStore.save(authCode, user.getId(), 180);

            // when
            userDeletionService.confirmDeleteByMailAuthCode(authCode);

            // then
            assertThat(userRepository.findById(user.getId())).isEmpty();
        }

        @Test
        void 유효하지_않은_인증코드이면_예외를_던진다() {
            // given
            String invalidAuthCode = "invalid-code";

            // when & then
            assertThatThrownBy(() -> userDeletionService.confirmDeleteByMailAuthCode(invalidAuthCode))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INVALID_MAIL_AUTH_CODE);
        }
    }

}
