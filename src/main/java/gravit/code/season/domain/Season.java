package gravit.code.season.domain;

import gravit.code.global.consts.TimeZoneConst;
import gravit.code.global.exception.domain.RestApiException;
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

import static gravit.code.global.exception.domain.CustomErrorCode.INVALID_SEASON_STATUS_TRANSITION;

@Getter
@Entity
@Table(name = "season",
        uniqueConstraints = @UniqueConstraint(name = "uk_season_key", columnNames = "season_key")
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Season {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "season_key", nullable = false, length = 16)
    private String seasonKey;

    @Column(name = "starts_at", nullable = false)
    private LocalDateTime startsAt;

    @Column(name = "ends_at", nullable = false)
    private LocalDateTime endsAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private SeasonStatus status;

    @Column(name = "tz", nullable = false)
    private String tz;

    @Builder(access = AccessLevel.PRIVATE)
    private Season(
            String seasonKey,
            LocalDateTime startsAt,
            LocalDateTime endsAt,
            SeasonStatus status
    ) {
        this.seasonKey = seasonKey;
        this.startsAt = startsAt;
        this.endsAt = endsAt;
        this.status = status;
        this.tz = TimeZoneConst.KST.getId();
    }

    public static Season prep(
            String seasonKey,
            LocalDateTime startsAt,
            LocalDateTime endsAt
    ){
        return Season.builder()
                .seasonKey(seasonKey)
                .startsAt(startsAt)
                .endsAt(endsAt)
                .status(SeasonStatus.PREP)
                .build();
    }

    public static Season active(
            String seasonKey,
            LocalDateTime startsAt,
            LocalDateTime endsAt
    ){
        return Season.builder()
                .seasonKey(seasonKey)
                .startsAt(startsAt)
                .endsAt(endsAt)
                .status(SeasonStatus.ACTIVE)
                .build();
    }

    public void finalizing() {
        validateStatus(SeasonStatus.ACTIVE);
        this.status = SeasonStatus.FINALIZING;
    }

    public void activate() {
        validateStatus(SeasonStatus.PREP);
        this.status = SeasonStatus.ACTIVE;
    }

    public void close() {
        validateStatus(SeasonStatus.FINALIZING);
        this.status = SeasonStatus.CLOSED;
    }

    private void validateStatus(SeasonStatus expected) {
        if (this.status != expected) {
            throw new RestApiException(INVALID_SEASON_STATUS_TRANSITION);
        }
    }

}
