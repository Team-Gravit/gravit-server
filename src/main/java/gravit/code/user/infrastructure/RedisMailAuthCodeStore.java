package gravit.code.user.infrastructure;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.service.port.MailAuthCodeStore;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.time.Duration;
import java.util.Collections;

import static gravit.code.user.util.RedisMailAuthCodeConstants.GETDEL_SCRIPT;
import static gravit.code.user.util.RedisMailAuthCodeConstants.makeMailAuthCodeKeyW;

@Repository
@RequiredArgsConstructor
public class RedisMailAuthCodeStore implements MailAuthCodeStore {

    private final RedisTemplate<String, String> redisTemplate;

    @Override
    public void save(String mailAuthCode, long userId, int expireTimeSeconds) {
        if (expireTimeSeconds <= 0) {
            throw new RestApiException(CustomErrorCode.REDIS_EXPIRE_TIME_INVALID);
        }

        // 만약 중복되는 키가 없으면 true, 중복 된다면 true
        Boolean result = redisTemplate.opsForValue()
                .setIfAbsent(
                        makeMailAuthCodeKeyW(mailAuthCode),
                        Long.toString(userId),
                        Duration.ofSeconds(expireTimeSeconds)
                );

        // auth code 가 중복되면 예외 발생
        if (!Boolean.TRUE.equals(result)) {
            throw new RestApiException(CustomErrorCode.REDIS_MAIL_AUTH_DUPLICATE);
        }
    }

    @Override
    public Long consume(String mailAuthCode) {
        // 한번 조회하고 나면 해당 키 삭제
        String userId = redisTemplate.execute(
                GETDEL_SCRIPT,
                Collections.singletonList(makeMailAuthCodeKeyW(mailAuthCode))
        );
        return Long.parseLong(userId);
    }
}
