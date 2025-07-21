package gravit.code.unitProgress.domain;

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
    private Long totalLessons;

    @Column(name = "completed_lessons", columnDefinition = "bigint", nullable = false)
    private Long completedLessons;

    @Column(name = "user_id",columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Column(name = "unit_id",columnDefinition = "bigint", nullable = false)
    private Long unitId;

    @Builder
    private UnitProgress(Long totalLessons, Long userId, Long unitId) {
        this.totalLessons = totalLessons;
        this.completedLessons = 0L;
        this.userId = userId;
        this.unitId = unitId;
    }

    public static UnitProgress create(Long totalLessons, Long userId, Long unitId) {
        return UnitProgress.builder()
                .totalLessons(totalLessons)
                .userId(userId)
                .unitId(unitId)
                .build();
    }

    public void updateCompletedLessons() {
        this.completedLessons++;
    }

    public Boolean isUnitCompleted() {
        return Objects.equals(completedLessons, totalLessons);
    }
}
