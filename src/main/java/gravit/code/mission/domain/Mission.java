package gravit.code.mission.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Mission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "mission_type",  nullable = false)
    private MissionType missionType;

    @Column(name = "progress_rate", nullable = false)
    private double progressRate;

    @Column(name = "is_completed", nullable = false)
    private boolean isCompleted;

    @Column(name = "user_id", nullable = false, unique = true)
    private long userId;

    @Version
    private long version;

    @Builder(access = AccessLevel.PRIVATE)
    private Mission(
            MissionType missionType,
            long userId
    ) {
        this.missionType = missionType;
        this.progressRate = 0.0;
        this.isCompleted = false;
        this.userId = userId;
        this.version = 0L;
    }

    public static Mission create(
            MissionType missionType,
            long userId
    ) {
        return Mission.builder()
                .missionType(missionType)
                .userId(userId)
                .build();
    }

    // 진행도를 통한 미션 완료 확인
    public void checkAndUpdateCompletionStatus() {
        if (this.progressRate >= 100.0) {
            this.isCompleted = true;
        }
    }

    // 레슨 x개 완료하기 관련
    public void updateCompleteLessonProgress() {
        double incrementValue = calculateCompleteLessonIncrement();
        this.progressRate = Math.min(this.progressRate + incrementValue, 100.0);
    }

    private double calculateCompleteLessonIncrement() {
        return switch (this.missionType.name()) {
            case "COMPLETE_LESSON_ONE" -> 100.0;
            case "COMPLETE_LESSONS_TWO" -> 50.0;
            case "COMPLETE_LESSONS_THREE" -> 33.4;
            default -> 0.0;
        };
    }

    // 정답율 100% 레슨 x개 완료하기 관련
    public void updatePerfectLessonProgress() {
        double incrementValue = calculatePerfectLessonIncrement();
        this.progressRate = Math.min(this.progressRate + incrementValue, 100.0);
    }

    private double calculatePerfectLessonIncrement() {
        return switch (this.missionType.name()) {
            case "PERFECT_LESSON_ONE" -> 100.0;
            case "PERFECT_LESSONS_TWO" -> 50.0;
            case "PERFECT_LESSONS_THREE" -> 33.4;
            default -> 0.0;
        };
    }

    // 학습 x분 완료하기 관련
    public void updateLearningMinutesProgress(int learningTime) {
        // 학습 시간 상한 5분으로 설정
        learningTime = Math.min(learningTime, 300);

        double targetMinutes = getTargetLearningMinutes();
        double studyTimeMinutes = learningTime / 60.0;
        double incrementValue = (studyTimeMinutes / targetMinutes) * 100.0;

        this.progressRate = Math.min(this.progressRate + incrementValue, 100.0);
    }

    private double getTargetLearningMinutes() {
        return switch (this.missionType.name()) {
            case "LEARNING_MINUTES_FIVE" -> 5.0;
            case "LEARNING_MINUTES_TEN" -> 10.0;
            case "LEARNING_MINUTES_FIFTEEN" -> 14.0;
            default -> 1.0;
        };
    }

    // 유저 팔로우하기 관련
    public void updateFollowProgress(){
        this.progressRate = 100.0;
    }

    public void reassignMission(){
        this.missionType = RandomMissionGenerator.getRandomMissionType();
        this.progressRate = 0.0;
        this.isCompleted = false;
    }
}