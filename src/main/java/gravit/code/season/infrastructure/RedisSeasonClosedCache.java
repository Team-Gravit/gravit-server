package gravit.code.season.infrastructure;

import gravit.code.season.service.port.SeasonClosedCache;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class RedisSeasonClosedCache implements SeasonClosedCache {

    public static final String LAST_CLOSED_SEASON_ID_KEY = "season:lastClosedSeasonId";

    private final RedisTemplate<String, String> redisTemplate;

    @Override
    public Optional<Long> getLastClosedSeasonId() {
        String value = redisTemplate.opsForValue().get(LAST_CLOSED_SEASON_ID_KEY);
        return value == null ? Optional.empty() : Optional.of(Long.parseLong(value));
    }

    @Override
    public void setLastClosedSeasonId(long seasonId) {
        redisTemplate.opsForValue().set(LAST_CLOSED_SEASON_ID_KEY, String.valueOf(seasonId));
    }
}
