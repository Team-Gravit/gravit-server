package gravit.code.user.batch;

import gravit.code.user.infrastructure.RedisUserCleanManager;
import gravit.code.user.service.UserDeletionService;
import io.lettuce.core.RedisConnectionException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Slf4j
@RequiredArgsConstructor
@Service
public class UserCleanScheduler {

    private final UserDeletionService userDeletionService;
    private final RedisUserCleanManager cleanManager;

    @Scheduled(
            cron = "0 0 * * * *", // 매 시간마다 한번씩
            zone = "Asia/Seoul"
    )
    public void cleanUsers() {
        List<Long> dueIds = cleanManager.allDueUserIds();

        if (dueIds.isEmpty()) {
            log.info("[UserCleanScheduler] 삭제 할 유저가 존재하지 않습니다.");
            return;
        }

        log.info("[UserCleanScheduler] 배치 시작. 대상: {} 명", dueIds.size());

        CleanResult result = new CleanResult();

        for (Long userId : dueIds) {
            processUser(userId, result);
        }

        log.info("[clean] 배치 종료. 성공: {}, 부분 성공: {}, 실패: {}",
                 result.success, result.partialSuccess, result.failed);
    }

    private void processUser(Long userId, CleanResult result) {
        try {
            userDeletionService.executeHardDelete(userId); // db 먼저 삭제해야 문제점이 줄어든다. db 성공 redis 실패해도 redis 의 ttl 정책으로 key는 사라지기 때문
            cleanManager.removeUserKey(userId);
            result.success++;
        } catch (DataAccessException e) {
            // DB 장애 - 재시도 가능하도록 Redis 키 유지
            result.failed++;
            log.error("[UserClean] DB 접근 실패. 다음 배치에서 재시도. userId: {}", userId);
        } catch (RedisConnectionException e) {
            // Redis 장애 - 재시도 가능하도록 Redis 키 유지
            result.partialSuccess++;
            log.warn("[UserClean] DB 삭제 완료 Redis 연결 실패. (ttl 로 key 자동정리) userId: {}", userId);
        } catch (Exception e) {
            // 예상치 못한 에러 - ttl 에 의존하여 재시도
            result.failed++;
            log.error("[UserClean] 예상치 못한 에러 발생 : userId: {}", userId);
        }
    }

    private static class CleanResult {
        int success = 0;
        int partialSuccess = 0;    // DB 성공, Redis 실패
        int failed = 0;
    }
}
