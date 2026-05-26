package gravit.code.league.fixture;

import gravit.code.league.domain.League;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class LeagueFixture {

    private final LeagueFixtureBuilder leagueFixtureBuilder;

    public League 브론즈_3() {
        return leagueFixtureBuilder.league().name("브론즈 3").maxLp(100).minLp(0).sortOrder(1).create();
    }

    public League 브론즈_2() {
        return leagueFixtureBuilder.league().name("브론즈 2").maxLp(200).minLp(101).sortOrder(2).create();
    }

    public League 브론즈_1() {
        return leagueFixtureBuilder.league().name("브론즈 1").maxLp(320).minLp(201).sortOrder(3).create();
    }

    public League 실버_3() {
        return leagueFixtureBuilder.league().name("실버 3").maxLp(460).minLp(321).sortOrder(4).create();
    }

    public League 실버_1() {
        return leagueFixtureBuilder.league().name("실버 1").maxLp(800).minLp(621).sortOrder(6).create();
    }

    public League 골드_3() {
        return leagueFixtureBuilder.league().name("골드 3").maxLp(1000).minLp(801).sortOrder(7).create();
    }

    public League 골드_1() {
        return leagueFixtureBuilder.league().name("골드 1").maxLp(1460).minLp(1221).sortOrder(9).create();
    }
}
