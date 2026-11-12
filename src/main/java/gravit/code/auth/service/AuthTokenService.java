package gravit.code.auth.service;

import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.dto.response.ReissueResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.REFRESH_TOKEN_EXPIRED;
import static gravit.code.global.exception.domain.CustomErrorCode.TOKEN_EMPTY;

@Slf4j
@RequiredArgsConstructor
@Service
public class AuthTokenService {

    private final AuthTokenProvider authTokenProvider;

    @Transactional
    public ReissueResponse reissue(String requestedRefreshToken) {
        if (requestedRefreshToken == null || requestedRefreshToken.isBlank()) {
            throw new RestApiException(TOKEN_EMPTY);
        }

        if (!authTokenProvider.isValidRefreshToken(requestedRefreshToken)) {
            throw new RestApiException(REFRESH_TOKEN_EXPIRED);
        }

        User user = authTokenProvider.parseUser(requestedRefreshToken);
        AccessToken newAccessToken = authTokenProvider.generateAccessToken(user);
        return ReissueResponse.from(newAccessToken);
    }

    public void logout(String refreshToken) {
        if (refreshToken == null || refreshToken.isBlank()) {
            return;
        }

        try {
            authTokenProvider.deleteRefreshToken(refreshToken);
        } catch (RestApiException e) {
            log.info("로그아웃 요청의 리프레시 토큰이 유효하지 않아 삭제를 건너뜁니다 : {}", e.getErrorCode());
        }
    }
}
