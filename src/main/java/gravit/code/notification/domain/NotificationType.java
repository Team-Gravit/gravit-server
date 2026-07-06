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

    private final NotificationActionType actionType;

    // 클라이언트 액션 라우팅용 FCM data payload. 키 계약은 프론트와 동일하게 맞춘다
    public Map<String, String> toPushData() {
        return Map.of(
                "type", name(),
                "actionType", actionType.name()
        );
    }

    // 액션 대상이 있는 경우(targetId) deeplink용으로 함께 실어 보낸다
    public Map<String, String> toPushData(Long targetId) {
        if (targetId == null) {
            return toPushData();
        }
        return Map.of(
                "type", name(),
                "actionType", actionType.name(),
                "targetId", String.valueOf(targetId)
        );
    }
}
