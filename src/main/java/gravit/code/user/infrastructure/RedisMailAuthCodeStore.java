package gravit.code.user.infrastructure;

import gravit.code.user.service.port.MailAuthCodeStore;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Repository;

import java.time.Duration;
import java.util.Collections;

@Repository
@RequiredArgsConstructor
public class RedisMailAuthCodeStore implements MailAuthCodeStore {

    private final RedisTemplate<String, String> redisTemplate;

    private static final String KEY_PREFIX = "user:delete:code:";

    // 원자적 GET+DEL (Redis 6.2+ 이면 하단 주석의 getDel 대체 가능)
    private static final DefaultRedisScript<String> GETDEL_SCRIPT =
            new DefaultRedisScript<>(
                    """
                    local v = redis.call('GET', KEYS[1])
                    if v then
                      redis.call('DEL', KEYS[1])
                    end
                    return v
                    """,
                    String.class
            );

    private String key(String code) { return KEY_PREFIX + code; }

    @Override
    public void save(String mailAuthCode, long userId, int expireTimeSeconds) {
        if (expireTimeSeconds <= 0) {
            throw new IllegalArgumentException("expireTimeSeconds must be > 0");
        }
        Boolean ok = redisTemplate.opsForValue()
                .setIfAbsent(
                        key(mailAuthCode),
                        Long.toString(userId),
                        Duration.ofSeconds(expireTimeSeconds)
                ); // SET NX EX

        if (!Boolean.TRUE.equals(ok)) {
            // 극히 드문 충돌 대비: 상위 레벨에서 코드 재생성/재시도
            throw new RuntimeException("이미 존재하는 인증 코드입니다: " + mailAuthCode);
        }
    }

    @Override
    public Long consume(String mailAuthCode) {
        String userId = redisTemplate.execute(
                GETDEL_SCRIPT,
                Collections.singletonList(key(mailAuthCode))
        );
        return Long.parseLong(userId);
    }
}
