package gravit.code.userLeague.fixture;

import gravit.code.league.domain.League;
import gravit.code.season.domain.Season;
import gravit.code.user.domain.User;
import gravit.code.userLeague.domain.UserLeague;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class UserLeagueFixture {

    private final UserLeagueFixtureBuilder userLeagueFixtureBuilder;

    public UserLeague 참여(User user, Season season, League league, int lp) {
        return userLeagueFixtureBuilder.userLeague()
                .user(user)
                .season(season)
                .league(league)
                .leaguePoint(lp) // LP 지정
                .create();
    }
}
