package gravit.code.mission.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.ErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.mission.service.MissionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Set;

@Slf4j
@Component
@RequiredArgsConstructor
public class MissionLessonRetryTarget implements RetrySweepTarget {

    private static final int MAX_ATTEMPTS = 10;

    private static final Set<ErrorCode> NON_RETRYABLE_ERRORS = Set.of(
            CustomErrorCode.MISSION_NOT_FOUND,
            CustomErrorCode.USER_NOT_FOUND
    );

    private final MissionService missionService;

    @Override
    public String queueKey() {
        return "mission-lesson-retry";
    }

    @Override
    public int maxAttempts() {
        return MAX_ATTEMPTS;
    }

    @Override
    public void reprocess(Map<String, String> fields) {
        long userId = Long.parseLong(fields.get("userId"));
        long lessonId = Long.parseLong(fields.get("lessonId"));
        int learningTime = Integer.parseInt(fields.get("learningTime"));
        int accuracy = Integer.parseInt(fields.get("accuracy"));

        try {
            missionService.handleLessonMission(userId, lessonId, learningTime, accuracy);
        } catch (RestApiException e) {
            if (NON_RETRYABLE_ERRORS.contains(e.getErrorCode())) {
                log.error("레슨 완료 미션 처리 실패(재시도 불가, 확인 필요), 재시도 종료: userId={}, errorCode={}", userId, e.getErrorCode(), e);
                return;
            }
            throw e;
        }
    }
}
