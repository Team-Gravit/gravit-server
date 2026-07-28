package gravit.code.auth.strategy.support;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.global.exception.domain.RestApiException;
import lombok.extern.slf4j.Slf4j;

import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_USER_INFO_INVALID;

@Slf4j
public final class OAuthUserInfoValidator {

    private OAuthUserInfoValidator() {
    }

    public static void validate(OAuthUserInfo userInfo) {
        boolean providerIdMissing = isBlank(userInfo.getProviderId());
        boolean emailMissing = isBlank(userInfo.getEmail());
        boolean nameMissing = isBlank(userInfo.getName());

        if (providerIdMissing || emailMissing || nameMissing) {
            log.warn("OAuth 사용자 정보에 필수 값이 누락되었습니다 : provider : {}, providerId 누락 : {}, email 누락 : {}, name 누락 : {}",
                    userInfo.getProvider(), providerIdMissing, emailMissing, nameMissing);
            throw new RestApiException(OAUTH_USER_INFO_INVALID);
        }
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
