package gravit.code.season.calendar;

import gravit.code.season.calendar.dto.SeasonDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;

import static org.assertj.core.api.SoftAssertions.assertSoftly;

class SeasonCalendarTest {

    private SeasonCalendar calendarFixedAt(int year, int month, int day) {
        Clock clock = Clock.fixed(
                LocalDate.of(year, month, day).atStartOfDay(ZoneId.of("Asia/Seoul")).toInstant(),
                ZoneId.of("Asia/Seoul")
        );
        return new SeasonCalendar(clock);
    }

    @Nested
    @DisplayName("currentSeason() 은")
    class CurrentSeason {

        @Test
        void 월_1_4는_S1_시즌이며_1월1일_시작_5월1일_종료다() {
            SeasonDto season = calendarFixedAt(2026, 3, 15).currentSeason();
            assertSoftly(softly -> {
                softly.assertThat(season.seasonKey()).isEqualTo("2026-S1");
                softly.assertThat(season.startsAt()).isEqualTo(LocalDateTime.of(2026, 1, 1, 0, 0));
                softly.assertThat(season.endsAt()).isEqualTo(LocalDateTime.of(2026, 5, 1, 0, 0));
            });
        }

        @Test
        void 월_5_8는_S2_시즌이며_5월1일_시작_9월1일_종료다() {
            SeasonDto season = calendarFixedAt(2026, 7, 1).currentSeason();
            assertSoftly(softly -> {
                softly.assertThat(season.seasonKey()).isEqualTo("2026-S2");
                softly.assertThat(season.startsAt()).isEqualTo(LocalDateTime.of(2026, 5, 1, 0, 0));
                softly.assertThat(season.endsAt()).isEqualTo(LocalDateTime.of(2026, 9, 1, 0, 0));
            });
        }

        @Test
        void 월_9_12는_S3_시즌이며_9월1일_시작_다음해_1월1일_종료다() {
            SeasonDto season = calendarFixedAt(2026, 11, 30).currentSeason();
            assertSoftly(softly -> {
                softly.assertThat(season.seasonKey()).isEqualTo("2026-S3");
                softly.assertThat(season.startsAt()).isEqualTo(LocalDateTime.of(2026, 9, 1, 0, 0));
                softly.assertThat(season.endsAt()).isEqualTo(LocalDateTime.of(2027, 1, 1, 0, 0));
            });
        }

        @Test
        void 시즌_경계일_첫날도_해당_시즌으로_분류된다() {
            assertSoftly(softly -> {
                softly.assertThat(calendarFixedAt(2026, 1, 1).currentSeason().seasonKey()).isEqualTo("2026-S1");
                softly.assertThat(calendarFixedAt(2026, 5, 1).currentSeason().seasonKey()).isEqualTo("2026-S2");
                softly.assertThat(calendarFixedAt(2026, 9, 1).currentSeason().seasonKey()).isEqualTo("2026-S3");
            });
        }
    }

    @Nested
    @DisplayName("nextFromEndsAt() 은")
    class NextFromEndsAt {

        @Test
        void S1_종료시각_기준으로_S2를_반환한다() {
            SeasonCalendar calendar = calendarFixedAt(2026, 1, 1);
            LocalDateTime s1End = LocalDateTime.of(2026, 5, 1, 0, 0);

            SeasonDto next = calendar.nextFromEndsAt(s1End);

            assertSoftly(softly -> {
                softly.assertThat(next.seasonKey()).isEqualTo("2026-S2");
                softly.assertThat(next.startsAt()).isEqualTo(s1End);
                softly.assertThat(next.endsAt()).isEqualTo(LocalDateTime.of(2026, 9, 1, 0, 0));
            });
        }

        @Test
        void S2_종료시각_기준으로_S3를_반환한다() {
            SeasonCalendar calendar = calendarFixedAt(2026, 1, 1);
            LocalDateTime s2End = LocalDateTime.of(2026, 9, 1, 0, 0);

            SeasonDto next = calendar.nextFromEndsAt(s2End);

            assertSoftly(softly -> {
                softly.assertThat(next.seasonKey()).isEqualTo("2026-S3");
                softly.assertThat(next.startsAt()).isEqualTo(s2End);
                softly.assertThat(next.endsAt()).isEqualTo(LocalDateTime.of(2027, 1, 1, 0, 0));
            });
        }

        @Test
        void S3_종료시각_기준으로_다음해_S1을_반환한다() {
            SeasonCalendar calendar = calendarFixedAt(2026, 1, 1);
            LocalDateTime s3End = LocalDateTime.of(2027, 1, 1, 0, 0);

            SeasonDto next = calendar.nextFromEndsAt(s3End);

            assertSoftly(softly -> {
                softly.assertThat(next.seasonKey()).isEqualTo("2027-S1");
                softly.assertThat(next.startsAt()).isEqualTo(s3End);
                softly.assertThat(next.endsAt()).isEqualTo(LocalDateTime.of(2027, 5, 1, 0, 0));
            });
        }
    }

    @Nested
    @DisplayName("seasonKey() 정적 메서드는")
    class SeasonKeyStatic {

        @Test
        void 날짜에_해당하는_시즌_키를_반환한다() {
            assertSoftly(softly -> {
                softly.assertThat(SeasonCalendar.seasonKey(LocalDate.of(2026, 1, 1))).isEqualTo("2026-S1");
                softly.assertThat(SeasonCalendar.seasonKey(LocalDate.of(2026, 5, 1))).isEqualTo("2026-S2");
                softly.assertThat(SeasonCalendar.seasonKey(LocalDate.of(2026, 9, 1))).isEqualTo("2026-S3");
                softly.assertThat(SeasonCalendar.seasonKey(LocalDate.of(2026, 12, 31))).isEqualTo("2026-S3");
            });
        }
    }
}
