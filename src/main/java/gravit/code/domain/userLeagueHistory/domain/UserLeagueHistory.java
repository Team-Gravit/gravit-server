package gravit.code.domain.userLeagueHistory.domain;

import gravit.code.domain.league.domain.League;
import gravit.code.domain.user.domain.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_league_history")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class UserLeagueHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "season_id", nullable = false)
    private Long seasonId;

    @ManyToOne(fetch = FetchType.LAZY)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "final_league_id", nullable = false)
    private League finalLeague;

    @Column(name = "final_rank", nullable = false)
    private Integer finalRank;

    @Column(name = "final_lp", nullable = false)
    private Integer finalLp;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Builder
    private UserLeagueHistory(Long seasonId, User user, League league, Integer finalLp) {
        this.seasonId = seasonId;
        this.user = user;
        this.finalLeague = league;
        this.finalLp = finalLp;
    }

    public static UserLeagueHistory create(Long seasonId, User user, League league, int finalLp) {
        return UserLeagueHistory.builder()
                .seasonId(seasonId).user(user).league(league).finalLp(finalLp).build();
    }
}
