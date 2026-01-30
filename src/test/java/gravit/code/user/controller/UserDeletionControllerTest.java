package gravit.code.user.controller;

import static org.assertj.core.api.AssertionsForClassTypes.assertThatThrownBy;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.service.DeletionAuthCodeManager;
import gravit.code.user.service.DeletionMailManager;
import gravit.code.user.service.UserDeletionService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
public class UserDeletionControllerTest {

    @InjectMocks
    private UserController controller;

    @Mock
    private UserDeletionService userDeletionService;

    @Mock
    private DeletionAuthCodeManager authCodeService;

    @Mock
    private DeletionMailManager mailService;

    @Mock
    private LoginUser loginUser;

    @Test
    @DisplayName("메일 발송 실패 시 Redis 키가 삭제된다 (보상 트랜잭션)")
    void 메일_발송_실패_시_보상_트랜잭션_실행() throws Exception {
        // Given
        Long userId = 1L;
        String authCode = "test-auth-code-123";
        String dest = "local";

        when(loginUser.getId()).thenReturn(userId);

        // Mocking
        when(authCodeService.generate(userId)).thenReturn(authCode);

        // 메일 발송 실패 시뮬레이션
        doThrow(new RestApiException(CustomErrorCode.MAIL_SEND_ERROR))
                .when(mailService)
                .requestDeletion(userId, dest, authCode);

        // When & Then
        assertThatThrownBy(() -> controller.deletionRequest(loginUser, dest))
                .isInstanceOf(RestApiException.class)
                .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.MAIL_SEND_ERROR);

        // Then
        verify(authCodeService, times(1)).remove(authCode);
    }
}
