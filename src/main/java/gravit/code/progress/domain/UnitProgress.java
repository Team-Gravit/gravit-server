package gravit.code.progress.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.Objects;

@Table(name = "unit_progress")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UnitProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "total_lessons", columnDefinition = "bigint", nullable = false)
    private long totalLessons;

    @Column(name = "completed_lessons", columnDefinition = "bigint", nullable = false)
    private long completedLessons;

    @Column(name = "user_id",columnDefinition = "bigint", nullable = false)
    private long userId;

    @Column(name = "unit_id",columnDefinition = "bigint", nullable = false)
    private long unitId;

    @Builder
    private UnitProgress(
            long totalLessons,
            long userId,
            long unitId
    ) {
        this.totalLessons = totalLessons;
        this.completedLessons = 0L;
        this.userId = userId;
        this.unitId = unitId;
    }

    public static UnitProgress create(
            long totalLessons,
            long userId,
            long unitId
    ) {
        return UnitProgress.builder()
                .totalLessons(totalLessons)
                .userId(userId)
                .unitId(unitId)
                .build();
    }

    public void updateCompletedLessons() {
        this.completedLessons++;
    }

    public Boolean isComplete() {
        return Objects.equals(completedLessons, totalLessons);
    }
}
