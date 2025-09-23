package gravit.code.auth.token;

import gravit.code.auth.domain.Subject;
import gravit.code.auth.domain.Token;
import gravit.code.auth.token.config.TokenProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class RedisTokenStorage {

    private final RedisTemplate<String, String> redisTemplate;

    public <T extends Token> T saveToken(Subject subject, T token) {
        redisTemplate.opsForValue().set(
                createKey(subject, token.getClass()),
                token.token(),
                TokenProperties.getExpireTime(token.getClass())
        );
        return token;
    }

    public <T extends Token> Optional<String> findToken(Subject subject, Class<T> tokenClass) {
        String key = createKey(subject, tokenClass);
        String foundTokenValue = redisTemplate.opsForValue().get(key);
        if (foundTokenValue == null || foundTokenValue.isBlank()) {
            return Optional.empty();
        }
        return Optional.of(foundTokenValue);
    }

    public <T extends Token> void deleteToken(Subject subject, Class<T> tokenClass) {
        String key = createKey(subject, tokenClass);
        redisTemplate.delete(key);
    }

    private <T extends Token> String createKey(Subject subject, Class<T> tokenClass) {
        return TokenProperties.getStorageKeyPrefix(tokenClass) + subject.value();
    }
}
