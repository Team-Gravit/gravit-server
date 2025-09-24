package gravit.code.badge.domain.user;

import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserMissionStat extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false)
    private Long userId;

    @Column(nullable = false)
    private int completedCount;

    @Builder
    private UserMissionStat(Long userId) {
        this.userId = userId;
        this.completedCount = 0;
    }

    public static UserMissionStat of(long userId) {
        return UserMissionStat.builder().userId(userId).build();
    }

    public void plusCompletedCount() {
        this.completedCount += 1;
    }
}
