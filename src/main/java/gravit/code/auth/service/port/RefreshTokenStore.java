package gravit.code.auth.service.port;

import gravit.code.auth.domain.LoginClient;

import java.time.Duration;
import java.util.Optional;

public interface RefreshTokenStore {
    void save(
            long userId,
            LoginClient client,
            String refreshToken,
            Duration ttl
    );

    Optional<String> find(
            long userId,
            LoginClient client
    );

    void delete(
            long userId,
            LoginClient client
    );

    void deleteAll(long userId);
}
