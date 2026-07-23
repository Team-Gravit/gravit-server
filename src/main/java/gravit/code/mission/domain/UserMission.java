package gravit.code.mission.domain;

import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Entity
@Table(
        name = "user_mission",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_user_mission_user_date",
                columnNames = {"user_id", "assigned_date"}
        )
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserMission extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Column(name = "mission_id", nullable = false)
    private long missionId;

    @Column(name = "assigned_date", nullable = false)
    private LocalDate assignedDate;

    @Column(name = "progress_count", nullable = false)
    private int progressCount;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Builder(access = AccessLevel.PRIVATE)
    private UserMission(
            long userId,
            long missionId,
            LocalDate assignedDate
    ) {
        this.userId = userId;
        this.missionId = missionId;
        this.assignedDate = assignedDate;
        this.progressCount = 0;
        this.completedAt = null;
    }

    public static UserMission assign(
            long userId,
            long missionId,
            LocalDate assignedDate
    ) {
        return UserMission.builder()
                .userId(userId)
                .missionId(missionId)
                .assignedDate(assignedDate)
                .build();
    }

    public boolean isCompleted() {
        return this.completedAt != null;
    }

    public void addProgress(int increment) {
        this.progressCount += increment;
    }
}
