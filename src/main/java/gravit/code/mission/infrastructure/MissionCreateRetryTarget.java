package gravit.code.mission.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.mission.service.MissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class MissionCreateRetryTarget implements RetrySweepTarget {

    public static final String QUEUE_KEY = "mission-create-retry";
    public static final String FIELD_USER_ID = "userId";

    private static final int MAX_ATTEMPTS = 10;

    private final MissionService missionService;

    @Override
    public String queueKey() {
        return QUEUE_KEY;
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        long userId = Long.parseLong(fields.get(FIELD_USER_ID));

        missionService.createMission(userId);
    }
}
