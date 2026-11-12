package gravit.code.notification.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum NotificationActionType {

    NONE("버튼 없음"),
    GO_TO_LEARNING("학습하러 가기"),
    GO_TO_NOTICE("공지사항 바로가기"),
    GO_TO_INQUIRY("문의 답변 보기"),
    FOLLOW_BACK("맞팔로우"),
    CONGRATULATE("축하하기");

    private final String label;
}
