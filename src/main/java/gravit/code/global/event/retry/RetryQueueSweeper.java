package gravit.code.global.event.retry;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Component
@RequiredArgsConstructor
@Slf4j
public class RetryQueueSweeper {

    private static final String RETRY_ID_FIELD = "__retryId";
    private static final String ATTEMPT_FIELD = "__attempt";
    private static final long BASE_BACKOFF_MS = 5_000L;
    private static final long MAX_BACKOFF_MS = 300_000L;
    private static final int SWEEP_BATCH_SIZE = 100;

    private final RedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper;
    private final List<RetrySweepTarget> targets;

    @Scheduled(fixedDelay = 30000)
    public void sweep() {
        for (RetrySweepTarget target : targets) {
            Set<String> due = redisTemplate.opsForZSet()
                    .rangeByScore(target.queueKey(), 0, System.currentTimeMillis(), 0, SWEEP_BATCH_SIZE);

            for (String json : due) {
                processDueEntry(target, json);
            }
        }
    }

    private void processDueEntry(
            RetrySweepTarget target,
            String json
    ) {
        Map<String, String> fields;
        int attempt;
        try {
            fields = objectMapper.readValue(json, new TypeReference<Map<String, String>>() {});
            attempt = Integer.parseInt(fields.remove(ATTEMPT_FIELD));
            fields.remove(RETRY_ID_FIELD);
        } catch (Exception e) {
            redisTemplate.opsForZSet().remove(target.queueKey(), json);
            log.error("재시도 큐 페이로드 파싱 실패, 데드레터 처리: queueKey={}, raw={}", target.queueKey(), json, e);
            return;
        }

        try {
            target.reprocess(fields);
            redisTemplate.opsForZSet().remove(target.queueKey(), json);
        } catch (Exception e) {
            redisTemplate.opsForZSet().remove(target.queueKey(), json);
            requeueOrDeadLetter(target, fields, attempt, e);
        }
    }

    private void requeueOrDeadLetter(
            RetrySweepTarget target,
            Map<String, String> fields,
            int attempt,
            Exception cause
    ) {
        if (attempt + 1 >= target.maxAttempts()) {
            log.error("재시도 한도 초과, 데드레터 처리: queueKey={}, fields={}", target.queueKey(), fields, cause);
            return;
        }

        try {
            fields.put(RETRY_ID_FIELD, UUID.randomUUID().toString());
            fields.put(ATTEMPT_FIELD, String.valueOf(attempt + 1));

            long backoffMs = Math.min(BASE_BACKOFF_MS * (1L << attempt), MAX_BACKOFF_MS);
            String requeued = objectMapper.writeValueAsString(fields);
            redisTemplate.opsForZSet().add(target.queueKey(), requeued, System.currentTimeMillis() + backoffMs);
        } catch (Exception e) {
            log.error("재시도 큐 재적재 실패, 유실: queueKey={}, fields={}", target.queueKey(), fields, e);
        }
    }
}
