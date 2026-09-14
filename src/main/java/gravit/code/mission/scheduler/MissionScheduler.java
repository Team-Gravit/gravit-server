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
                log.error("미션 배정 청크 실패 - 마지막 성공 유저 id: {}", lastUserId, e);
                break;
            }
        }
    }
}
