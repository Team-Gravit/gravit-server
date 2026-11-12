package gravit.code.user.infrastructure;

import lombok.experimental.UtilityClass;
import org.springframework.data.redis.core.script.DefaultRedisScript;

@UtilityClass
public class RedisMailAuthCodeConstants {

    public static final String KEY_PREFIX = "user:delete:code:";

    public static final DefaultRedisScript<String> GETDEL_SCRIPT =
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

    public static String makeMailAuthCodeKeyW(String mailAuthCode) {
        return KEY_PREFIX + mailAuthCode;
    }
}
