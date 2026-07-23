package gravit.code.mission.domain;

import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Mission extends BaseEntity {

    private static final int PERFECT_ACCURACY = 100;
    private static final double MAX_RATE = 100.0;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, unique = true)
    private String code;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "target_type", nullable = false)
    private MissionTargetType targetType;

    @Column(name = "target_value", nullable = false)
    private int targetValue;

    @Column(name = "max_progress_per_event")
    private Integer maxProgressPerEvent;

    @Column(name = "award_xp", nullable = false)
    private int awardXp;

    @Column(name = "weight", nullable = false)
    private int weight;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private MissionStatus status;

    @Builder(access = AccessLevel.PRIVATE)
    private Mission(
            String code,
            String title,
            MissionTargetType targetType,
            int targetValue,
            Integer maxProgressPerEvent,
            int awardXp,
            int weight,
            MissionStatus status
    ) {
        this.code = code;
        this.title = title;
        this.targetType = targetType;
        this.targetValue = targetValue;
        this.maxProgressPerEvent = maxProgressPerEvent;
        this.awardXp = awardXp;
        this.weight = weight;
        this.status = status;
    }

    public static Mission create(
            String code,
            String title,
            MissionTargetType targetType,
            int targetValue,
            Integer maxProgressPerEvent,
            int awardXp,
            int weight,
            MissionStatus status
    ) {
        return Mission.builder()
                .code(code)
                .title(title)
                .targetType(targetType)
                .targetValue(targetValue)
                .maxProgressPerEvent(maxProgressPerEvent)
                .awardXp(awardXp)
                .weight(weight)
                .status(status)
                .build();
    }

    // 레슨 완료 이벤트가 이 미션의 progress_count를 얼마나 올리는가. 해당 없으면 0
    public int calculateLessonIncrement(
            int accuracy,
            int learningTime
    ) {
        int rawProgress = switch (this.targetType) {
            case COMPLETE_LESSON -> 1;
            case PERFECT_LESSON -> accuracy == PERFECT_ACCURACY ? 1 : 0;
            case LEARNING_SECONDS -> learningTime;
            case FOLLOW_FRIEND -> 0;
        };

        return capPerEvent(rawProgress);
    }

    public int calculateFollowIncrement() {
        return this.targetType == MissionTargetType.FOLLOW_FRIEND ? 1 : 0;
    }

    public boolean isAchieved(int progressCount) {
        return progressCount >= this.targetValue;
    }

    public double calculateProgressRate(int progressCount) {
        double rate = Math.min((double) progressCount / this.targetValue * MAX_RATE, MAX_RATE);
        return Math.round(rate * 10) / 10.0;
    }

    private int capPerEvent(int rawProgress) {
        if (this.maxProgressPerEvent == null)
            return rawProgress;

        return Math.min(rawProgress, this.maxProgressPerEvent);
    }
}
