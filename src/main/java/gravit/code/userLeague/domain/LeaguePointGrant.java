package gravit.code.userLeague.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Table(
        name = "league_point_grant",
        uniqueConstraints = @UniqueConstraint(
                name = "ux_league_point_grant_source",
                columnNames = {"source_type", "source_id", "user_id"}
        )
)
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class LeaguePointGrant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "source_type", nullable = false)
    private LeaguePointSource sourceType;

    @Column(name = "source_id", nullable = false)
    private long sourceId;

    @Column(name = "points", nullable = false)
    private int points;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Builder(access = AccessLevel.PRIVATE)
    private LeaguePointGrant(
            long userId,
            LeaguePointSource sourceType,
            long sourceId,
            int points,
            LocalDateTime createdAt
    ) {
        this.userId = userId;
        this.sourceType = sourceType;
        this.sourceId = sourceId;
        this.points = points;
        this.createdAt = createdAt;
    }

    public static LeaguePointGrant create(
            long userId,
            LeaguePointSource sourceType,
            long sourceId,
            int points,
            LocalDateTime createdAt
    ) {
        return LeaguePointGrant.builder()
                .userId(userId)
                .sourceType(sourceType)
                .sourceId(sourceId)
                .points(points)
                .createdAt(createdAt)
                .build();
    }
}
