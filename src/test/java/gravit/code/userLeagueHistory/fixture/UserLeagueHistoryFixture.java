package gravit.code.userLeagueHistory.fixture;

import gravit.code.league.domain.League;
import gravit.code.season.domain.Season;
import gravit.code.user.domain.User;
import gravit.code.userLeagueHistory.domain.UserLeagueHistory;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class UserLeagueHistoryFixture {

    private final UserLeagueHistoryFixtureBuilder builder;

    public UserLeagueHistory 히스토리_생성(Season season, User user, League league, int rank, int lp) {
        return builder.history()
                .season(season)
                .user(user)
                .finalLeague(league)
                .finalRank(rank)
                .finalLp(lp)
                .create();
    }
}
