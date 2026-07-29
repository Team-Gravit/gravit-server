package gravit.code.global.config;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.Map;

@ConfigurationProperties(prefix = "redirect")
public record RedirectDestProps(
        Map<String, String> dests
) {
    public String resolveBaseUrl(String dest) {
        String baseUrl = (dests == null || dest == null) ? null : dests.get(dest);

        if (baseUrl == null || baseUrl.isBlank()) {
            throw new RestApiException(CustomErrorCode.DEST_NOT_VALID);
        }

        return baseUrl;
    }
}
