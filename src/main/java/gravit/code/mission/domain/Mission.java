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

    @Column(name = "progress_rate", columnDefinition = "double precision", nullable = false)
    private Double progressRate;

    @Column(name = "user_id", columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Builder
    private Mission(MissionType missionType, Long userId) {
        this.missionType = missionType;
        this.progressRate = 0.0;
        this.userId = userId;
    }

    public static Mission create(MissionType missionType, Long userId) {
        return Mission.builder()
                .missionType(missionType)
                .userId(userId)
                .build();
    }
}
