package gravit.code.auth.service.oauth;

import gravit.code.auth.service.port.OAuthStateStore;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.UUID;

import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_STATE_INVALID;

@Service
@RequiredArgsConstructor
public class OAuthStateService {

    private static final Duration STATE_TTL = Duration.ofMinutes(10);

    private final OAuthStateStore oAuthStateStore;

    public String issue(String provider) {
        String state = UUID.randomUUID().toString();

        oAuthStateStore.save(state, provider, STATE_TTL);

        return state;
    }

    public void verify(
            String provider,
            String state
    ) {
        if (state == null || state.isBlank()) {
            throw new RestApiException(OAUTH_STATE_INVALID);
        }

        boolean matched = oAuthStateStore.consume(state)
                .map(provider::equals)
                .orElse(false);

        if (!matched) {
            throw new RestApiException(OAUTH_STATE_INVALID);
        }
    }
}
