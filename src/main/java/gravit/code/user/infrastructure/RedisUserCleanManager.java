package gravit.code.user.infrastructure;

import java.time.Duration;
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

    private static final String DELETION_SCHEDULE_KEY = "user:clean:due";
    private final Clock clock;

    /**
     * 삭제 예정 유저를 Redis에 저장 (7일 후 유저 완전 삭제를 위해)
     */
    public void storeDeletionUser(long userId) {
        ZonedDateTime now = ZonedDateTime.now(clock);
        Instant deleteScheduledAt  = now.plusDays(7).toInstant();
        long deleteScheduledTimestamp = deleteScheduledAt.getEpochSecond();

        redisTemplate.opsForZSet()  // redis sorted set 에 userId를 멤버로 추가, deleteTimestamp 를 스코어로 저장(단순 숫자 ttl 아님)
                .add(DELETION_SCHEDULE_KEY, Long.toString(userId), deleteScheduledTimestamp);

        redisTemplate.expire(DELETION_SCHEDULE_KEY, Duration.ofDays(10)); // key 가 삭제되지 않고 무한히 남는 경우를 막기 위해 ttl 설정
    }

    /**
     * 현재 시각 기준 삭제 시각이 도래한 유저 ID 목록 조회
     */
    public List<Long> allDueUserIds() {
        ZonedDateTime currentTime = ZonedDateTime.now(clock);
        long currentTimestamp = currentTime.toInstant().getEpochSecond();

        Set<String> userIds = redisTemplate.opsForZSet() // Redis Sorted Set에서 스코어 범위로 멤버를 조회, 스코어가 "음수 무한대 ~ 현재 타임스탬프 범위" 인 모든 멤버 반환
                .rangeByScore(DELETION_SCHEDULE_KEY, Double.NEGATIVE_INFINITY, currentTimestamp);

        if (userIds == null || userIds.isEmpty()) return List.of();

        return userIds.stream()
                .map(Long::parseLong)
                .toList();
    }

    /**
     * 삭제 완료된 유저를 Redis 스케줄에서 제거
     */
    public void removeUserKey(long userId) {
        redisTemplate.opsForZSet()
                .remove(DELETION_SCHEDULE_KEY, Long.toString(userId));
    }

}
