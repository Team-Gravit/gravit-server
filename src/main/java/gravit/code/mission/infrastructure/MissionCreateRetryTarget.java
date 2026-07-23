package gravit.code.mission.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.mission.service.MissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

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
        long userId = Long.parseLong(fields.get("userId"));

        // assignToday의 insertIfAbsent가 ON CONFLICT DO NOTHING으로 멱등하므로 중복 가드가 필요 없다
        missionService.createMission(userId);
    }
}
