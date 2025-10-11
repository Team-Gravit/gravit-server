package gravit.code.user.infrastructure;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.Instant;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.Set;

@Component
@RequiredArgsConstructor
public class RedisUserCleanManager {

    private final RedisTemplate<String, String> redisTemplate;

    private static final String DUE_KEY = "user:clean:due";
    private final Clock clock;

    public void storeDeletionUser(long userId) {
        ZonedDateTime now = ZonedDateTime.now(clock);
        Instant purgeAt = now.plusDays(7).toInstant();

        redisTemplate.opsForZSet()
                .add(DUE_KEY, Long.toString(userId), purgeAt.getEpochSecond());
    }

    public List<Long> allDueUserIds() {
        ZonedDateTime now = ZonedDateTime.now(clock);
        long nowEpoch = now.toInstant().getEpochSecond();

        Set<String> members = redisTemplate.opsForZSet()
                .rangeByScore(DUE_KEY, Double.NEGATIVE_INFINITY, nowEpoch);

        if (members == null || members.isEmpty()) return List.of();

        return members.stream().map(Long::parseLong).toList();
    }

    public void removeUserKey(long userId) {
        redisTemplate.opsForZSet().remove(DUE_KEY, Long.toString(userId));
    }

}
