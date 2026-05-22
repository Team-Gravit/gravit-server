package gravit.code.league.fixture;

import gravit.code.league.domain.League;
import gravit.code.league.repository.LeagueRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class LeagueFixtureBuilder {

    private final LeagueRepository leagueRepository;

    private String name;
    private int maxLp;
    private int minLp;
    private int sortOrder;

    public LeagueFixtureBuilder league() {
        return new LeagueFixtureBuilder(leagueRepository);
    }

    public LeagueFixtureBuilder name(String name) { this.name = name; return this; }
    public LeagueFixtureBuilder maxLp(int maxLp) { this.maxLp = maxLp; return this; }
    public LeagueFixtureBuilder minLp(int minLp) { this.minLp = minLp; return this; }
    public LeagueFixtureBuilder sortOrder(int sortOrder) { this.sortOrder = sortOrder; return this; }

    public League create() {
        return leagueRepository.save(League.create(name, maxLp, minLp, sortOrder));
    }
}
