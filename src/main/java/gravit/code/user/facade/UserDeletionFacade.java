package gravit.code.user.facade;

import gravit.code.auth.dto.internal.AppleStoredTokenDto;
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
        Optional<AppleStoredTokenDto> appleStoredToken = findAppleRefreshToken(userId);

        if (!userDeletionService.cleanUserDeletion(userId)) {
            return false;
        }

        appleStoredToken.ifPresent(storedToken -> revokeAppleToken(userId, storedToken));

        interviewAudioDeletionService.deleteAllBySessionIds(voiceSessionIds);

        return true;
    }

    private Optional<AppleStoredTokenDto> findAppleRefreshToken(long userId) {
        try {
            return appleCredentialService.findRefreshToken(userId);
        } catch (Exception e) {
            log.error("실제 삭제 때 Apple 토큰 조회 실패, 철회 없이 삭제를 진행: userId={}", userId, e);
            return Optional.empty();
        }
    }

    private void revokeAppleToken(
            long userId,
            AppleStoredTokenDto storedToken
    ) {
        try {
            appleOAuthService.revokeRefreshToken(storedToken.refreshToken(), storedToken.client());
            log.info("실제 삭제 때 남은 Apple 토큰 철회 완료: userId={}, client={}", userId, storedToken.client());
        } catch (Exception e) {
            log.error("실제 삭제 때 Apple 토큰 철회 실패, 토큰은 회원 데이터와 함께 삭제됨: userId={}", userId, e);
        }
    }
}
