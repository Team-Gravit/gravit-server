package gravit.code.auth.infrastructure.config;

import static gravit.code.global.exception.domain.CustomErrorCode.PROVIDER_INVALID;

import gravit.code.global.exception.domain.RestApiException;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "oauth.android")
public record OAuthAndroidProps(
        Google google,
        Kakao kakao
) {
    public record Google(
            String issuer,
            String clientId
    ) {}

    public record Kakao(
            String issuer,
            String clientId
    ) {}

    public String getIssuer(String provider) {
        return switch (provider.toLowerCase()) {
            case "google" -> google.issuer();
            case "kakao" -> kakao.issuer();
            default -> throw new RestApiException(PROVIDER_INVALID);
        };
    }

    public String getClientId(String provider) {
        return switch (provider.toLowerCase()) {
            case "google" -> google.clientId();
            case "kakao" -> kakao.clientId();
            default -> throw new RestApiException(PROVIDER_INVALID);
        };
    }
}
