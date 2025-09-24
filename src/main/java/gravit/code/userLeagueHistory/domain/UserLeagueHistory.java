package gravit.code.userLeagueHistory.domain;

import gravit.code.global.entity.BaseEntity;
import gravit.code.league.domain.League;
import gravit.code.season.domain.Season;
import gravit.code.user.domain.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Entity
@Table(name = "user_league_history")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class UserLeagueHistory extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "season_id", nullable = false)
    private Season season;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "final_league_id", nullable = false)
    private League finalLeague;

    @Column(name = "final_rank")
    private int finalRank;

    @Column(name = "final_lp", nullable = false)
    private int finalLp;

    @Builder
    private UserLeagueHistory(
            Season season,
            User user,
            League league,
            int finalRank,
            int finalLp
    ) {
        this.season = season;
        this.user = user;
        this.finalLeague = league;
        this.finalRank = finalRank;
        this.finalLp = finalLp;
    }

    public static UserLeagueHistory create(
            Season season,
            User user,
            League league,
            int finalRank,
            int finalLp
    ) {
        return UserLeagueHistory.builder()
                .season(season).user(user).league(league).finalRank(finalRank).finalLp(finalLp).build();
    }
}
