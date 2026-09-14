package gravit.code.mission.infrastructure;

import gravit.code.global.event.retry.RetrySweepTarget;
import gravit.code.global.exception.domain.ErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.mission.service.MissionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Set;

import static gravit.code.global.exception.domain.CustomErrorCode.MISSION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;

@Slf4j
@Component
@RequiredArgsConstructor
public class MissionLessonRetryTarget implements RetrySweepTarget {

    public static final String QUEUE_KEY = "mission-lesson-retry";
    public static final String FIELD_USER_ID = "userId";
    public static final String FIELD_LESSON_ID = "lessonId";
    public static final String FIELD_LEARNING_TIME = "learningTime";
    public static final String FIELD_ACCURACY = "accuracy";

    private static final int MAX_ATTEMPTS = 10;

    private static final Set<ErrorCode> NON_RETRYABLE_ERRORS = Set.of(
            MISSION_NOT_FOUND,
            USER_NOT_FOUND
    );

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
        long lessonId = Long.parseLong(fields.get(FIELD_LESSON_ID));
        int learningTime = Integer.parseInt(fields.get(FIELD_LEARNING_TIME));
        int accuracy = Integer.parseInt(fields.get(FIELD_ACCURACY));

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
