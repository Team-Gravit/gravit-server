package gravit.code.season.infrastructure;

import gravit.code.season.service.port.SeasonPopupSeenStore;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.time.Duration;

@Component
@RequiredArgsConstructor
public class RedisSeasonPopupSeenStore implements SeasonPopupSeenStore {

    private final RedisTemplate<String, String> redisTemplate;
    private static final String KEY = "season:seen:%d:%d";

    @Override
    public boolean markSeenIfFirst(long userId, long seasonId, Duration ttl) {
        String key = KEY.formatted(seasonId, userId);
        String seenFlag = "1";
        Boolean isNotSeen = redisTemplate.opsForValue().setIfAbsent(key, seenFlag, ttl);
        return Boolean.TRUE.equals(isNotSeen); // 키를 처음 만들면 true, 아니면 false
    }
}
