package gravit.code.season.domain;

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

    // 2026-S1 (4개월 단위: S1=1~4월, S2=5~8월, S3=9~12월)
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

    @Builder
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
        this.tz = "Asia/Seoul";
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

    /** ACTIVE -> FINALIZING */
    public void finalizing() {
        validateStatus(SeasonStatus.ACTIVE);
        this.status = SeasonStatus.FINALIZING;
    }

    /** PREP -> ACTIVE */
    public void activate() {
        validateStatus(SeasonStatus.PREP);
        this.status = SeasonStatus.ACTIVE;
    }

    /** FINALIZING -> CLOSED */
    public void close() {
        validateStatus(SeasonStatus.FINALIZING);
        this.status = SeasonStatus.CLOSED;
    }

    private void validateStatus(SeasonStatus expected) {
        if (this.status != expected) {
            throw new RuntimeException();
        }
    }

}
