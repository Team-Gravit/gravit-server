package gravit.code.userLeague.fixture;

import gravit.code.league.domain.League;
import gravit.code.season.domain.Season;
import gravit.code.user.domain.User;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.repository.UserLeagueRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class UserLeagueFixtureBuilder {

    private final UserLeagueRepository userLeagueRepository;

    private User user;
    private Season season;
    private League league;

    private int leaguePoint = 0;

    public UserLeagueFixtureBuilder userLeague() {
        return new UserLeagueFixtureBuilder(userLeagueRepository);
    }

    public UserLeagueFixtureBuilder user(User user) { this.user = user; return this; }
    public UserLeagueFixtureBuilder season(Season season) { this.season = season; return this; }
    public UserLeagueFixtureBuilder league(League league) { this.league = league; return this; }
    public UserLeagueFixtureBuilder leaguePoint(int leaguePoint) { this.leaguePoint = leaguePoint; return this; }

    public UserLeague create() {
        UserLeague userLeague = UserLeague.create(user, season, league);
        userLeague.addLeaguePoints(leaguePoint); // LP 추가
        return userLeagueRepository.save(userLeague);
    }
}
