package gravit.code.mission.domain;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum MissionType {

    // 레슨 x개 완료하기
    COMPLETE_LESSON_ONE(1, "COMPLETE_LESSON_ONE", 10),
    COMPLETE_LESSONS_TWO(2, "COMPLETE_LESSONS_TWO", 15),
    COMPLETE_LESSONS_THREE(3, "COMPLETE_LESSONS_THREE", 20),

    // 레슨 정답율 100%로 x개 완료하기
    PERFECT_LESSON_ONE(4, "PERFECT_LESSON_ONE", 30),
    PERFECT_LESSONS_TWO(5, "PERFECT_LESSONS_TWO", 35),
    PERFECT_LESSONS_THREE(6, "PERFECT_LESSONS_THREE", 40),

    // 학습 x분 완료하기
    LEARNING_MINUTES_TEN(7, "LEARNING_MINUTES_TEN", 25),
    LEARNING_MINUTES_FIFTEEN(8, "LEARNING_MINUTES_FIFTEEN", 35),
    LEARNING_MINUTES_TWENTY(9, "LEARNING_MINUTES_TWENTY", 40),

    // 새로운 친구 팔로우하기
    FOLLOW_NEW_FRIEND(10, "FOLLOW_NEW_FRIEND", 40);

    private final Integer missionId;
    private final String type;
    private final Integer awardXp;

}
