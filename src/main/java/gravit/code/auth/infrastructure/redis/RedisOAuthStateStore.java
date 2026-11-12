package gravit.code.auth.infrastructure.redis;

import gravit.code.auth.service.port.OAuthStateStore;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.time.Duration;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class RedisOAuthStateStore implements OAuthStateStore {

    private static final String KEY_PREFIX = "oauthState:";

    private final RedisTemplate<String, String> redisTemplate;

    @Override
    public void save(
            String state,
            String provider,
            Duration ttl
    ) {
        redisTemplate.opsForValue().set(KEY_PREFIX + state, provider, ttl);
    }

    @Override
    public Optional<String> consume(String state) {
        return Optional.ofNullable(redisTemplate.opsForValue().getAndDelete(KEY_PREFIX + state));
    }
}
