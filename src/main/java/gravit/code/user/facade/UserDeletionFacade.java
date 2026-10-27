package gravit.code.user.facade;

import gravit.code.auth.service.oauth.apple.AppleCredentialService;
import gravit.code.auth.service.oauth.apple.AppleOAuthService;
import gravit.code.global.annotation.Facade;
import gravit.code.interview.service.InterviewAudioDeletionService;
import gravit.code.user.service.UserDeletionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.util.List;
import java.util.Optional;

@Slf4j
@Facade
@RequiredArgsConstructor
public class UserDeletionFacade {

    private final UserDeletionService userDeletionService;
    private final InterviewAudioDeletionService interviewAudioDeletionService;
    private final AppleCredentialService appleCredentialService;
    private final AppleOAuthService appleOAuthService;

    public boolean cleanUserDeletion(long userId) {
        List<Long> voiceSessionIds = interviewAudioDeletionService.getVoiceSessionIds(userId);
        Optional<String> appleRefreshToken = appleCredentialService.findRefreshToken(userId);

        if (!userDeletionService.cleanUserDeletion(userId)) {
            return false;
        }

        appleRefreshToken.ifPresent(refreshToken -> revokeAppleToken(userId, refreshToken));

        interviewAudioDeletionService.deleteAllBySessionIds(voiceSessionIds);

        return true;
    }

    private void revokeAppleToken(
            long userId,
            String refreshToken
    ) {
        try {
            appleOAuthService.revokeRefreshToken(refreshToken);
            log.info("실제 삭제 때 남은 Apple 토큰 철회 완료: userId={}", userId);
        } catch (Exception e) {
            log.error("실제 삭제 때 Apple 토큰 철회 실패, 토큰은 회원 데이터와 함께 삭제됨: userId={}", userId, e);
        }
    }
}
