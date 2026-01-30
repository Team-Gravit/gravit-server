package gravit.code.user.support;

import gravit.code.global.consts.RedirectHostConst;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.config.UserDeleteMailProps;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

@Component
@RequiredArgsConstructor
public class UserDeletionUrlBuilder {

    private static final String DELETE_PATH = "/user/me/delete/page";

    public String buildConfirmationUrl(String dest, String mailAuthCode){
        String baseUrl = getBaseUrl(dest);

        return UriComponentsBuilder
                .fromUriString(baseUrl)
                .path(DELETE_PATH)
                .queryParam("mailAuthCode", mailAuthCode)
                .build(true)
                .toUriString();

    }

    private String getBaseUrl(String dest) {
        String base = RedirectHostConst.DEST_BASE.get(dest);

        if (base == null || base.isBlank()) {
            throw new RestApiException(CustomErrorCode.DEST_NOT_VALID);
        }

        return base;
    }
}
