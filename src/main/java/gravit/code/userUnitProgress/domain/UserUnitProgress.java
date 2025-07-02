package gravit.code.userUnitProgress.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "user_unit_progress")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserUnitProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "completed_lessons", columnDefinition = "bigint", nullable = false)
    private Long completedLessons;

    @Column(name = "user_id",columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Column(name = "unit_id",columnDefinition = "bigint", nullable = false)
    private Long unitId;

    @Builder
    private UserUnitProgress(Long userId, Long unitId) {
        this.completedLessons = 0L;
        this.userId = userId;
        this.unitId = unitId;
    }

    public static UserUnitProgress create(Long userId, Long unitId) {
        return UserUnitProgress.builder()
                .userId(userId)
                .unitId(unitId)
                .build();
    }
}
