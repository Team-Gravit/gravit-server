package gravit.code.auth.service;

import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.dto.response.ReissueResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@RequiredArgsConstructor
@Service
public class AuthTokenService {

    private final AuthTokenProvider authTokenProvider;
    private final UserRepository userRepository;

    @Transactional
    public ReissueResponse reissue(String requestedRefreshToken) {
        // 리프레시 토큰 확인
        if (!authTokenProvider.isValidRefreshToken(requestedRefreshToken)) {
            throw new RestApiException(CustomErrorCode.REFRESH_TOKEN_EXPIRED);
        }

        // 액세스 토큰 재발급
        User user = authTokenProvider.parseUser(requestedRefreshToken);
        AccessToken newAccessToken = authTokenProvider.generateAccessToken(user);
        return ReissueResponse.from(newAccessToken);
    }
}
