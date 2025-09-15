package gravit.code.mission.domain;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum MissionType {

    // 레슨 x개 완료하기
    COMPLETE_LESSON_ONE(1, "레슨 1개 완료하기", 10, 20),
    COMPLETE_LESSONS_TWO(2, "레슨 2개 완료하기", 15, 10),
    COMPLETE_LESSONS_THREE(3, "레슨 3개 완료하기", 20, 5),

    // 레슨 정답율 100%로 x개 완료하기
    PERFECT_LESSON_ONE(4, "정답율 100%로 레슨 1개 완료하기", 30, 16),
    PERFECT_LESSONS_TWO(5, "정답율 100%로 레슨 2개 완료하기", 35, 8),
    PERFECT_LESSONS_THREE(6, "정답율 100%로 레슨 3개 완료하기", 40, 6),

    // 학습 x분 완료하기
    LEARNING_MINUTES_TEN(7, "학습 10분 완료하기", 25, 15),
    LEARNING_MINUTES_FIFTEEN(8, "학습 15분 완료하기", 35, 10),
    LEARNING_MINUTES_TWENTY(9, "학습 20분 완료하기", 40, 5),

    // 새로운 친구 팔로우하기
    FOLLOW_NEW_FRIEND(10, "새로운 친구 팔로우하기", 40, 5);

    private final Integer missionId;
    private final String description;
    private final Integer awardXp;
    private final Integer ticket;

}
