package gravit.code.notification.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.util.Map;

import static gravit.code.notification.domain.NotificationActionType.*;

@Getter
@RequiredArgsConstructor
public enum NotificationType {

    CONSECUTIVE_LEARNING_WARNING(GO_TO_LEARNING),  // 3.1  연속학습 끊길 위기
    DAILY_INCOMPLETE(GO_TO_LEARNING),  // 3.2  오늘 학습 미완료
    INACTIVITY(GO_TO_LEARNING),        // 3.3  장기 미접속
    SEASON_ENDING(GO_TO_LEARNING),     // 3.7  시즌 종료 임박
    SEASON_RESET(NONE),                // 3.8  시즌 종료 + 새 시즌 시작
    FOLLOW(FOLLOW_BACK),               // 3.9  팔로우
    CONGRATULATION(NONE),              // 3.10 축하하기 받음
    FRIEND_ACTIVITY(CONGRATULATE),     // 3.11 친구 활동
    NOTICE(GO_TO_NOTICE),              // 3.12 공지사항
    NEW_CONTENT(GO_TO_LEARNING),       // 3.13 새 콘텐츠 업데이트
    INQUIRY_ANSWERED(GO_TO_INQUIRY);   // 문의 답변 등록(명세 외, 현행 유지)

    private static final String TYPE_KEY = "type";
    private static final String ACTION_TYPE_KEY = "actionType";
    private static final String TARGET_ID_KEY = "targetId";

    private final NotificationActionType actionType;

    public Map<String, String> toPushData() {
        return Map.of(
                TYPE_KEY, name(),
                ACTION_TYPE_KEY, actionType.name()
        );
    }

    public Map<String, String> toPushData(Long targetId) {
        if (targetId == null) {
            return toPushData();
        }
        return Map.of(
                TYPE_KEY, name(),
                ACTION_TYPE_KEY, actionType.name(),
                TARGET_ID_KEY, String.valueOf(targetId)
        );
    }
}
