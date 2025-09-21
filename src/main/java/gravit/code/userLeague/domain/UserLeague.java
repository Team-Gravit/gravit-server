package gravit.code.userLeague.domain;

import gravit.code.league.domain.League;
import gravit.code.season.domain.Season;
import gravit.code.user.domain.User;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Table(name = "user_league")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class UserLeague {

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

    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Builder
    private UserLeague(User user, Season season, League league) {
        this.user = user;
        this.season = season;
        this.league = league;
        this.lp = 0;
    }

    public static UserLeague create(User user, Season season, League league) {
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
