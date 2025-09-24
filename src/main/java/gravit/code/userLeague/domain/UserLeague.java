package gravit.code.userLeague.domain;

import gravit.code.global.entity.BaseEntity;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.season.domain.Season;
import gravit.code.user.domain.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Table(name = "user_league")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class UserLeague extends BaseEntity {

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
    @JoinColumn(name = "league_id", nullable = false)
    private League league;

    @Column(name = "league_point", columnDefinition = "integer", nullable = false)
    private int lp;

    @Builder
    private UserLeague(
            User user,
            Season season,
            League league
    ) {
        this.user = user;
        this.season = season;
        this.league = league;
        this.lp = 0;
    }

    public static UserLeague create(
            User user,
            Season season,
            League league
    ) {
        return UserLeague.builder()
                .user(user)
                .season(season)
                .league(league)
                .build();
    }

    public int addLeaguePoints(int points) {
        if(points <= 0){
            throw new RestApiException(CustomErrorCode.LEAGUE_POINT_MUST_BE_POSITIVE);
        }
        this.lp += points;
        return lp;
    }

    public void updateLeagueIfDifferent(League newLeague) {
        if(validateAndCheckDifferent(newLeague)){
            this.league = newLeague;
        }
    }

    private boolean validateAndCheckDifferent(League newLeague) {
        if(newLeague == null){
            throw new RestApiException(CustomErrorCode.LEAGUE_INVALID);
        }
        else return !this.league.equals(newLeague);
    }

}
