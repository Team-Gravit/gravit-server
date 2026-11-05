package gravit.code.auth.service.port;

import java.time.Duration;
import java.util.Optional;

public interface OAuthStateStore {
    void save(
            String state,
            String provider,
            Duration ttl
    );

    Optional<String> consume(String state);
}
