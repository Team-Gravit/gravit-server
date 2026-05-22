package gravit.code.season.fixture;

import gravit.code.season.domain.Season;
import gravit.code.season.repository.SeasonRepository;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class SeasonFixtureBuilder {

    private final SeasonRepository seasonRepository;

    private String seasonKey = "2025-S1";
    private LocalDateTime startsAt = LocalDateTime.of(2025, 1, 1, 0, 0);
    private LocalDateTime endsAt = LocalDateTime.of(2025, 5, 1, 0, 0);

    public SeasonFixtureBuilder season() {
        return new SeasonFixtureBuilder(seasonRepository);
    }

    public SeasonFixtureBuilder seasonKey(String seasonKey) { this.seasonKey = seasonKey; return this; }
    public SeasonFixtureBuilder startsAt(LocalDateTime startsAt) { this.startsAt = startsAt; return this; }
    public SeasonFixtureBuilder endsAt(LocalDateTime endsAt) { this.endsAt = endsAt; return this; }

    public Season createActive() {
        return seasonRepository.save(Season.active(seasonKey, startsAt, endsAt));
    }

    public Season createPrep() {
        return seasonRepository.save(Season.prep(seasonKey, startsAt, endsAt));
    }

    public Season createFinalizing() {
        Season season = Season.active(seasonKey, startsAt, endsAt);
        season.finalizing();
        return seasonRepository.save(season);
    }

    public Season createClosed() {
        Season season = Season.active(seasonKey, startsAt, endsAt);
        season.finalizing();
        season.close();
        return seasonRepository.save(season);
    }
}
