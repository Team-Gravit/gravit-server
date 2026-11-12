package gravit.code.auth.infrastructure.config;

import gravit.code.global.exception.domain.RestApiException;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

import static gravit.code.global.exception.domain.CustomErrorCode.PROVIDER_INVALID;

@Validated
@ConfigurationProperties(prefix = "oauth.ios")
public record OAuthIosProps(
        @Valid @NotNull Google google,
        @Valid @NotNull Kakao kakao
) implements OAuthIdTokenProps {
    public record Google(
            @NotBlank String issuer,
            @NotBlank String clientId
    ) {}

    public record Kakao(
            @NotBlank String issuer,
            @NotBlank String clientId
    ) {}

    @Override
    public String getIssuer(String provider) {
        return switch (provider.toLowerCase()) {
            case "google" -> google.issuer();
            case "kakao" -> kakao.issuer();
            default -> throw new RestApiException(PROVIDER_INVALID);
        };
    }

    @Override
    public String getClientId(String provider) {
        return switch (provider.toLowerCase()) {
            case "google" -> google.clientId();
            case "kakao" -> kakao.clientId();
            default -> throw new RestApiException(PROVIDER_INVALID);
        };
    }
}
