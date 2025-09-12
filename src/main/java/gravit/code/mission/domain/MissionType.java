package gravit.code.mission.domain;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum MissionType {

    // 레슨 x개 완료하기
    COMPLETE_ONE_LESSONS(1, "COMPLETE_ONE_LESSON", 20),
    COMPLETE_TWO_LESSONS(2, "COMPLETE_TWO_LESSONS", 25),
    COMPLETE_THREE_LESSONS(3, "COMPLETE_THREE_LESSONS", 30),

    // 레슨 100%로 x개 완료하기
    PERFECT_ONE_LESSON_SCORE(4, "PERFECT_ONE_LESSON_SCORE", 30),
    PERFECT_TWO_LESSON_SCORE(5, "PERFECT_TWO_LESSONS_SCORE", 35),
    PERFECT_THREE_LESSON_SCORE(6, "PERFECT_THREE_LESSONS_SCORE", 40),

    // 학습 x분 완료하기
    LEARNING_FIVE_MINUTES(7, "LEARNING_FIVE_MINUTES", 25),
    LEARNING_TEN_MINUTES(8, "LEARNING_TEN_MINUTES", 30),
    LEARNING_FIFTEEN_MINUTES(9, "LEARNING_FIFTEEN_MINUTES", 35),

    // 새로운 친구 팔로우하기
    FOLLOW_NEW_FRIEND(10, "FOLLOW_NEW_FRIEND", 40);

    private final Integer missionId;
    private final String type;
    private final Integer xp;

}
