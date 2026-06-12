package gravit.code.notification.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum NotificationActionType {

    NONE("버튼 없음"),                     // 액션 없음 (targetId 없음)
    GO_TO_LEARNING("학습하러 가기"),         // 학습 메인(targetId 없음) 또는 레슨 딥링크(targetId = unit)
    GO_TO_NOTICE("공지사항 바로가기"),       // targetId = noticeId
    FOLLOW_BACK("맞팔로우"),               // targetId = 상대 userId
    UNFOLLOW("팔로우 취소"),               // targetId = 상대 userId (이미 맞팔로우한 경우)
    CONGRATULATE("축하하기");              // targetId = feedId

    private final String label;
}
