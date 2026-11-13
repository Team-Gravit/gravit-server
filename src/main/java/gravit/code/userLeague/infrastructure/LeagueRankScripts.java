package gravit.code.userLeague.infrastructure;

import lombok.experimental.UtilityClass;
import org.springframework.data.redis.core.script.DefaultRedisScript;

@UtilityClass
public class LeagueRankScripts {

    public static final long PLACED = 1L;

    public static final DefaultRedisScript<Long> PLACE_SCRIPT =
            new DefaultRedisScript<>(
                    """
                    local score = tonumber(ARGV[3])
                    for _, key in ipairs(KEYS) do
                      local existing = redis.call('ZSCORE', key, ARGV[1])
                      if existing and tonumber(existing) > score then
                        return 0
                      end
                    end
                    local target = tonumber(ARGV[2])
                    for i, key in ipairs(KEYS) do
                      if i ~= target then
                        redis.call('ZREM', key, ARGV[1])
                      end
                    end
                    redis.call('ZADD', KEYS[target], ARGV[3], ARGV[1])
                    return 1
                    """,
                    Long.class
            );

    public static final DefaultRedisScript<Long> EVICT_SCRIPT =
            new DefaultRedisScript<>(
                    """
                    local removed = 0
                    for _, key in ipairs(KEYS) do
                      removed = removed + redis.call('ZREM', key, ARGV[1])
                    end
                    return removed
                    """,
                    Long.class
            );
}
