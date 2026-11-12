package gravit.code.auth.support;

import gravit.code.global.consts.RedirectHostConst;
import gravit.code.global.exception.domain.RestApiException;
import org.springframework.stereotype.Component;

import static gravit.code.global.exception.domain.CustomErrorCode.DEST_NOT_VALID;

@Component
public class RedirectHostResolver {

    public String resolve(
            String origin,
            String dest
    ) {
        if (origin != null && RedirectHostConst.DEST_BASE.containsValue(origin)) {
            return origin;
        }

        String destBase = dest == null ? null : RedirectHostConst.DEST_BASE.get(dest);
        if (destBase != null) {
            return destBase;
        }

        throw new RestApiException(DEST_NOT_VALID);
    }
}
