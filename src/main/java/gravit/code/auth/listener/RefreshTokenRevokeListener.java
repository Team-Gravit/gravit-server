package gravit.code.auth.listener;

import gravit.code.auth.service.AuthTokenProvider;
import gravit.code.user.dto.event.UserWithdrawnEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Slf4j
@Component
@RequiredArgsConstructor
public class RefreshTokenRevokeListener {

    private final AuthTokenProvider authTokenProvider;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleUserWithdrawn(UserWithdrawnEvent event) {
        long userId = event.userId();

        try {
            authTokenProvider.deleteAllRefreshTokens(userId);
            log.info("탈퇴 회원의 리프레시 토큰 삭제 완료: userId={}", userId);
        } catch (Exception e) {
            log.error("탈퇴 회원의 리프레시 토큰 삭제 실패: userId={}", userId, e);
        }
    }
}
