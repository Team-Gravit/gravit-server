package gravit.code.userLeagueHistory.fixture;

import gravit.code.league.domain.League;
import gravit.code.season.domain.Season;
import gravit.code.user.domain.User;
import gravit.code.userLeagueHistory.domain.UserLeagueHistory;
import gravit.code.userLeagueHistory.repository.UserLeagueHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class UserLeagueHistoryFixtureBuilder {

    private final UserLeagueHistoryRepository historyRepository;

    private Season season;
    private User user;
    private League finalLeague;
    private int finalRank = 1;
    private int finalLp = 0;

    public UserLeagueHistoryFixtureBuilder history() {
        return new UserLeagueHistoryFixtureBuilder(historyRepository);
    }

    public UserLeagueHistoryFixtureBuilder season(Season season) { this.season = season; return this; }
    public UserLeagueHistoryFixtureBuilder user(User user) { this.user = user; return this; }
    public UserLeagueHistoryFixtureBuilder finalLeague(League finalLeague) {this.finalLeague = finalLeague; return this; }
    public UserLeagueHistoryFixtureBuilder finalRank(int finalRank) { this.finalRank = finalRank; return this; }
    public UserLeagueHistoryFixtureBuilder finalLp(int finalLp) { this.finalLp = finalLp; return this; }

    public UserLeagueHistory create() {
        return historyRepository.save(UserLeagueHistory.create(season, user, finalLeague, finalRank, finalLp));
    }
}
