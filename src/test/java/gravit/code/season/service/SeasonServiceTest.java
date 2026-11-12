package gravit.code.season.service;

import gravit.code.season.domain.Season;
import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;


@TCSpringBootTest
class SeasonServiceTest {

    @Autowired SeasonService seasonService;
    @Autowired SeasonFixture seasonFixture;

    @Test
    void ACTIVE_시즌이_존재하면_해당_시즌을_그대로_반환한다() {
        // given
        seasonFixture.진행중인_시즌("2025-S2",
                              LocalDateTime.of(2025, 5, 1, 0, 0),
                              LocalDateTime.of(2025, 9, 1, 0, 0));

        // when
        Season result = seasonService.getOrCreateActiveSeason();

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.getStatus()).isEqualTo(SeasonStatus.ACTIVE);
            softly.assertThat(result.getSeasonKey()).isEqualTo("2025-S2");
        });
    }

    @Test
    void ACTIVE_시즌이_없고_PREP_시즌이_존재하면_PREP_시즌을_반환한다() {
        // given
        seasonFixture.준비중인_시즌("2025-S2",
                              LocalDateTime.of(2025, 5, 1, 0, 0),
                              LocalDateTime.of(2025, 9, 1, 0, 0));

        // when
        Season result = seasonService.getOrCreateActiveSeason();

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.getStatus()).isEqualTo(SeasonStatus.PREP);
            softly.assertThat(result.getSeasonKey()).isEqualTo("2025-S2");
        });
    }

    @Test
    void ACTIVE와_PREP이_없고_FINALIZING만_존재하면_다음_시즌을_PREP으로_생성하여_반환한다() {
        // given
        seasonFixture.정산중인_시즌("2025-S2",
                              LocalDateTime.of(2025, 5, 1, 0, 0),
                              LocalDateTime.of(2025, 9, 1, 0, 0));

        // when
        Season result = seasonService.getOrCreateActiveSeason();

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.getStatus()).isEqualTo(SeasonStatus.PREP);
            softly.assertThat(result.getSeasonKey()).isEqualTo("2025-S3");
            softly.assertThat(result.getStartsAt()).isEqualTo(LocalDateTime.of(2025, 9, 1, 0, 0));
            softly.assertThat(result.getEndsAt()).isEqualTo(LocalDateTime.of(2026, 1, 1, 0, 0));
        });
    }

    @Test
    void FINALIZING_시즌이_이전_시즌이고_시계가_다음_기간에_있어도_FINALIZING_endsAt_기준으로_다음_시즌을_생성한다() {
        // given
        // S1이 FINALIZING 상태로 남아있고, 시계는 이미 S2 기간(2025-08-05)
        // calendar.currentSeason().endsAt() = 2025-09-01 이지만
        // finalizingSeason.getEndsAt() = 2025-05-01 이므로 S2가 생성되어야 한다
        seasonFixture.정산중인_시즌("2025-S1",
                              LocalDateTime.of(2025, 1, 1, 0, 0),
                              LocalDateTime.of(2025, 5, 1, 0, 0));

        // when
        Season result = seasonService.getOrCreateActiveSeason();

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.getStatus()).isEqualTo(SeasonStatus.PREP);
            softly.assertThat(result.getSeasonKey()).isEqualTo("2025-S2");
            softly.assertThat(result.getStartsAt()).isEqualTo(LocalDateTime.of(2025, 5, 1, 0, 0));
            softly.assertThat(result.getEndsAt()).isEqualTo(LocalDateTime.of(2025, 9, 1, 0, 0));
        });
    }

    @Test
    void 시즌이_전혀_없는_초기_상태이면_현재_달력_기준_ACTIVE_시즌을_생성하여_반환한다() {
        // given & when
        Season result = seasonService.getOrCreateActiveSeason();

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.getStatus()).isEqualTo(SeasonStatus.ACTIVE);
            softly.assertThat(result.getSeasonKey()).isEqualTo("2025-S2");
            softly.assertThat(result.getStartsAt()).isEqualTo(LocalDateTime.of(2025, 5, 1, 0, 0));
            softly.assertThat(result.getEndsAt()).isEqualTo(LocalDateTime.of(2025, 9, 1, 0, 0));
        });
    }

    @Test
    void ACTIVE_시즌의_종료_시각을_조회한다() {
        // given
        LocalDateTime endsAt = LocalDateTime.of(2025, 9, 1, 0, 0);
        seasonFixture.진행중인_시즌("2025-S2", LocalDateTime.of(2025, 5, 1, 0, 0), endsAt);

        // when
        Optional<LocalDateTime> result = seasonService.getActiveSeasonEndsAt();

        // then
        assertThat(result).contains(endsAt);
    }

    @Test
    void ACTIVE_시즌이_없으면_종료_시각_조회_결과가_비어있다() {
        // given - CLOSED 시즌만 존재 (ACTIVE 아님)
        seasonFixture.종료된_시즌("2025-S1");

        // when
        Optional<LocalDateTime> result = seasonService.getActiveSeasonEndsAt();

        // then
        assertThat(result).isEmpty();
    }
}
