package gravit.code.mission.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.mission.service.MissionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class MissionCreateRetryTarget implements RetrySweepTarget {

    private static final int MAX_ATTEMPTS = 10;

    private final MissionService missionService;

    @Override
    public String queueKey() {
        return "mission-create-retry";
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        Long userId = Long.valueOf(fields.get("userId"));

        try {
            missionService.createMission(userId);
        } catch (RestApiException e) {
            if (e.getErrorCode() == CustomErrorCode.MISSION_CONFLICT) {
                log.warn("미션 이미 존재, 재시도 종료: userId={}", userId);
                return;
            }
            throw e;
        }
    }
}
