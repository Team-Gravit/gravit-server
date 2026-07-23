package gravit.code.mission.fixture;

import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionStatus;
import gravit.code.mission.domain.MissionTargetType;
import gravit.code.mission.domain.UserMission;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 미션 정의(Mission)와 유저 진행(UserMission) 픽스처.
 * <p>
 * 정의는 Flyway가 시딩하지만 DatabaseCleaner가 매 테스트 전에 모든 테이블을 TRUNCATE 하므로
 * 테스트에는 시딩 행이 남지 않는다. 필요한 정의만 테스트가 직접 저장해서 쓴다.
 * ACTIVE 정의를 하나만 저장하면 WeightedMissionPicker의 선택이 결정적이 된다.
 */
public class MissionFixture {

    public static Mission 미션정의_레슨_1개() {
        return Mission.create(
                "COMPLETE_LESSON_ONE",
                "레슨 1개 완료하기",
                MissionTargetType.COMPLETE_LESSON,
                1,
                null,
                10,
                20,
                MissionStatus.ACTIVE
        );
    }

    public static Mission 미션정의_레슨_3개() {
        return Mission.create(
                "COMPLETE_LESSONS_THREE",
                "레슨 3개 완료하기",
                MissionTargetType.COMPLETE_LESSON,
                3,
                null,
                20,
                5,
                MissionStatus.ACTIVE
        );
    }

    public static Mission 미션정의_정답율_100_레슨_1개() {
        return Mission.create(
                "PERFECT_LESSON_ONE",
                "정답율 100%로 레슨 1개 완료하기",
                MissionTargetType.PERFECT_LESSON,
                1,
                null,
                30,
                16,
                MissionStatus.ACTIVE
        );
    }

    public static Mission 미션정의_학습_5분() {
        return Mission.create(
                "LEARNING_MINUTES_FIVE",
                "학습 5분 완료하기",
                MissionTargetType.LEARNING_SECONDS,
                300,
                300,
                25,
                15,
                MissionStatus.ACTIVE
        );
    }

    public static Mission 미션정의_학습_15분() {
        return Mission.create(
                "LEARNING_MINUTES_FIFTEEN",
                "학습 15분 완료하기",
                MissionTargetType.LEARNING_SECONDS,
                900,
                300,
                40,
                5,
                MissionStatus.ACTIVE
        );
    }

    public static Mission 미션정의_팔로우() {
        return Mission.create(
                "FOLLOW_NEW_FRIEND",
                "새로운 친구 팔로우하기",
                MissionTargetType.FOLLOW_FRIEND,
                1,
                null,
                40,
                5,
                MissionStatus.ACTIVE
        );
    }

    public static Mission 비활성_미션정의() {
        return Mission.create(
                "INACTIVE_MISSION",
                "비활성 미션",
                MissionTargetType.COMPLETE_LESSON,
                1,
                null,
                10,
                20,
                MissionStatus.INACTIVE
        );
    }

    public static UserMission 오늘_배정된_미션(
            long userId,
            long missionId,
            LocalDate assignedDate
    ) {
        return UserMission.assign(userId, missionId, assignedDate);
    }

    public static UserMission 진행중_미션(
            long userId,
            long missionId,
            LocalDate assignedDate,
            int progressCount
    ) {
        UserMission userMission = UserMission.assign(userId, missionId, assignedDate);
        ReflectionTestUtils.setField(userMission, "progressCount", progressCount);
        return userMission;
    }

    public static UserMission 완료된_미션(
            long userId,
            long missionId,
            LocalDate assignedDate,
            int progressCount,
            LocalDateTime completedAt
    ) {
        UserMission userMission = 진행중_미션(userId, missionId, assignedDate, progressCount);
        ReflectionTestUtils.setField(userMission, "completedAt", completedAt);
        return userMission;
    }
}
