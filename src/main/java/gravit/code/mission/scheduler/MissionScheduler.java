package gravit.code.mission.scheduler;

import gravit.code.mission.service.MissionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.LocalDate;

@Slf4j
@Component
@RequiredArgsConstructor
public class MissionScheduler {

    private static final int CHUNK_SIZE = 500;

    private final MissionService missionService;
    private final Clock clock;

    // 트랜잭션 없는 루프. 청크 하나가 트랜잭션 하나라 트랜잭션 길이가 유저 수와 무관하게 고정된다
    @Scheduled(cron = "0 0 0 * * *", zone = "Asia/Seoul")
    public void assignDailyMissions() {
        LocalDate today = LocalDate.now(clock);
        long lastUserId = 0L;

        while (true) {
            try {
                long newLastUserId = missionService.assignChunk(today, lastUserId, CHUNK_SIZE);
                if (newLastUserId == lastUserId)
                    break;

                lastUserId = newLastUserId;
            } catch (Exception e) {
                // 실패한 청크의 마지막 유저 id를 알 수 없어 재시도하면 같은 청크를 도는 무한 루프가 될 수 있다.
                // 중단하고 배정받지 못한 유저는 조회 폴백에 맡긴다
                log.error("미션 배정 청크 실패 - 마지막 성공 유저 id: {}", lastUserId, e);
                break;
            }
        }
    }
}
