package gravit.code.season.infrastructure;

import gravit.code.season.service.port.SeasonClosedCache;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class RedisSeasonClosedCache implements SeasonClosedCache {
    private final RedisTemplate<String, String> redisTemplate;
    private static final String KEY = "season:lastClosedSeasonId";

    @Override
    public Optional<Long> getLastClosedSeasonId() {
        String value = redisTemplate.opsForValue().get(KEY);
        return value == null ? Optional.empty() : Optional.of(Long.parseLong(value));
    }

    @Override
    public void setLastClosedSeasonId(long seasonId) {
        redisTemplate.opsForValue().set(KEY, String.valueOf(seasonId));
    }
}
