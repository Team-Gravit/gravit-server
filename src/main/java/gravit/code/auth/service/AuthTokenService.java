package gravit.code.auth.service;

import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.dto.response.ReissueResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.REFRESH_TOKEN_EXPIRED;

@RequiredArgsConstructor
@Service
public class AuthTokenService {

    private final AuthTokenProvider authTokenProvider;

    @Transactional
    public ReissueResponse reissue(String requestedRefreshToken) {
        if (!authTokenProvider.isValidRefreshToken(requestedRefreshToken)) {
            throw new RestApiException(REFRESH_TOKEN_EXPIRED);
        }

        User user = authTokenProvider.parseUser(requestedRefreshToken);
        AccessToken newAccessToken = authTokenProvider.generateAccessToken(user);
        return ReissueResponse.from(newAccessToken);
    }
}
