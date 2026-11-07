package gravit.code.auth.infrastructure.redis;

import gravit.code.auth.domain.LoginClient;
import gravit.code.auth.domain.RefreshToken;
import gravit.code.auth.service.port.RefreshTokenStore;
import gravit.code.auth.token.config.TokenProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.time.Duration;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class RedisRefreshTokenStore implements RefreshTokenStore {

    private static final String KEY_DELIMITER = ":";

    private final RedisTemplate<String, String> redisTemplate;

    @Override
    public void save(
            long userId,
            LoginClient client,
            String refreshToken,
            Duration ttl
    ) {
        redisTemplate.opsForValue().set(key(userId, client), refreshToken, ttl);
    }

    @Override
    public Optional<String> find(
            long userId,
            LoginClient client
    ) {
        return Optional.ofNullable(redisTemplate.opsForValue().get(key(userId, client)));
    }

    @Override
    public void delete(
            long userId,
            LoginClient client
    ) {
        redisTemplate.delete(key(userId, client));
    }

    @Override
    public void deleteAll(long userId) {
        List<String> keys = Arrays.stream(LoginClient.values())
                .map(client -> key(userId, client))
                .toList();
        redisTemplate.delete(keys);
    }

    private String key(
            long userId,
            LoginClient client
    ) {
        return TokenProperties.getStorageKeyPrefix(RefreshToken.class) + userId + KEY_DELIMITER + client.name();
    }
}
