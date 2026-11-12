package gravit.code.season.fixture;

import gravit.code.season.domain.Season;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

import java.time.LocalDateTime;

@TestComponent
@RequiredArgsConstructor
public class SeasonFixture {

    private final SeasonFixtureBuilder seasonFixtureBuilder;

    public Season 진행중인_시즌(String seasonKey) {
        return seasonFixtureBuilder.season().seasonKey(seasonKey).createActive();
    }

    public Season 종료된_시즌(String seasonKey) {
        return seasonFixtureBuilder.season().seasonKey(seasonKey).createClosed();
    }

    public Season 진행중인_시즌(String seasonKey, LocalDateTime startsAt, LocalDateTime endsAt) {
        return seasonFixtureBuilder.season().seasonKey(seasonKey).startsAt(startsAt).endsAt(endsAt).createActive();
    }

    public Season 준비중인_시즌(String seasonKey, LocalDateTime startsAt, LocalDateTime endsAt) {
        return seasonFixtureBuilder.season().seasonKey(seasonKey).startsAt(startsAt).endsAt(endsAt).createPrep();
    }

    public Season 정산중인_시즌(String seasonKey, LocalDateTime startsAt, LocalDateTime endsAt) {
        return seasonFixtureBuilder.season().seasonKey(seasonKey).startsAt(startsAt).endsAt(endsAt).createFinalizing();
    }
}
