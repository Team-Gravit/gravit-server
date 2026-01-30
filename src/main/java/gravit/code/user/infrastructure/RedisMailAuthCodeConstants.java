package gravit.code.user.infrastructure;

import lombok.experimental.UtilityClass;
import org.springframework.data.redis.core.script.DefaultRedisScript;

@UtilityClass
public class RedisMailAuthCodeConstants {

    // MailAuthCode 저장할 key 구조
    public static final String KEY_PREFIX = "user:delete:code:";

    // GET + DEL (원자적 소비) Lua 스크립트 원문
    // 여러 명령을 한 번에 원자적으로 실행해야할 떄
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

    // 실제 key(key : prefix + MailAuthCode) 생성
    public static String makeMailAuthCodeKey(String mailAuthCode) {
        return KEY_PREFIX + mailAuthCode;
    }
    
}
