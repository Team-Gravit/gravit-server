package gravit.code.auth.listener;

import gravit.code.auth.service.oauth.apple.AppleCredentialService;
import gravit.code.auth.service.oauth.apple.AppleOAuthService;
import gravit.code.user.dto.event.UserWithdrawnEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Slf4j
@Component
@RequiredArgsConstructor
public class AppleTokenRevokeListener {

    private final AppleCredentialService appleCredentialService;
    private final AppleOAuthService appleOAuthService;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleUserWithdrawn(UserWithdrawnEvent event) {
        long userId = event.userId();

        try {
            appleCredentialService.findRefreshToken(userId)
                    .ifPresent(refreshToken -> {
                        appleOAuthService.revokeRefreshToken(refreshToken);
                        appleCredentialService.deleteByUserId(userId);
                        log.info("탈퇴 회원의 Apple 토큰 철회 완료: userId={}", userId);
                    });
        } catch (Exception e) {
            log.error("탈퇴 회원의 Apple 토큰 철회 실패, 실제 삭제 때 다시 시도: userId={}", userId, e);
        }
    }
}
