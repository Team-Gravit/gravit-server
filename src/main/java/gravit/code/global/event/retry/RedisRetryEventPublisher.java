package gravit.code.global.event.retry;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Component
@RequiredArgsConstructor
@Slf4j
public class RedisRetryEventPublisher implements RetryEventPublisher {

    private static final String RETRY_ID_FIELD = "__retryId";
    private static final String ATTEMPT_FIELD = "__attempt";
    private static final String INITIAL_ATTEMPT = "0";

    private final RedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper;

    @Override
    public void publish(
            String queueKey,
            Map<String, String> fields
    ) {
        try {
            Map<String, String> payload = new HashMap<>(fields);
            payload.put(RETRY_ID_FIELD, UUID.randomUUID().toString());
            payload.put(ATTEMPT_FIELD, INITIAL_ATTEMPT);

            String json = objectMapper.writeValueAsString(payload);
            redisTemplate.opsForZSet().add(queueKey, json, System.currentTimeMillis());
        } catch (Exception e) {
            log.error("재시도 큐 적재 실패: queueKey={}", queueKey, e);
        }
    }
}
