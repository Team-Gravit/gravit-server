package gravit.code.dailyLearningRecord.service;

import gravit.code.dailyLearningRecord.domain.DailyLearningRecord;
import gravit.code.dailyLearningRecord.dto.response.DailySolvedCountResponse;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningRecordResponse;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningReportResponse;
import gravit.code.dailyLearningRecord.repository.DailyLearningRecordRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class DailyLearningRecordServiceIntegrationTest {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    @Autowired
    private DailyLearningRecordService dailyLearningRecordService;

    @Autowired
    private DailyLearningRecordRepository dailyLearningRecordRepository;

    private DailyLearningRecord saveSolvedRecord(long userId, LocalDate date) {
        DailyLearningRecord record = DailyLearningRecord.create(userId, date);
        record.increaseSolvedLessonCount();
        return dailyLearningRecordRepository.save(record);
    }

    @Nested
    @DisplayName("주간 학습 기록을 조회할 때")
    class GetWeeklyLearningRecordResponse {

        @Test
        void 모든_요일에_학습_기록이_있으면_모두_true를_반환한다() {
            // given
            long userId = 1L;
            LocalDate monday = LocalDate.now(KST).with(DayOfWeek.MONDAY);
            for (int i = 0; i < 7; i++) {
                dailyLearningRecordRepository.save(DailyLearningRecord.create(userId, monday.plusDays(i)));
            }

            // when
            WeeklyLearningRecordResponse result = dailyLearningRecordService.getWeeklyLearningRecord(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.MONDAY()).isTrue();
                softly.assertThat(result.TUESDAY()).isTrue();
                softly.assertThat(result.WEDNESDAY()).isTrue();
                softly.assertThat(result.THURSDAY()).isTrue();
                softly.assertThat(result.FRIDAY()).isTrue();
                softly.assertThat(result.SATURDAY()).isTrue();
                softly.assertThat(result.SUNDAY()).isTrue();
            });
        }

        @Test
        void 월요일과_수요일만_학습했다면_해당_요일만_true를_반환한다() {
            // given
            long userId = 1L;
            LocalDate monday = LocalDate.now(KST).with(DayOfWeek.MONDAY);
            dailyLearningRecordRepository.save(DailyLearningRecord.create(userId, monday));
            dailyLearningRecordRepository.save(DailyLearningRecord.create(userId, monday.plusDays(2)));

            // when
            WeeklyLearningRecordResponse result = dailyLearningRecordService.getWeeklyLearningRecord(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.MONDAY()).isTrue();
                softly.assertThat(result.TUESDAY()).isFalse();
                softly.assertThat(result.WEDNESDAY()).isTrue();
                softly.assertThat(result.THURSDAY()).isFalse();
                softly.assertThat(result.FRIDAY()).isFalse();
                softly.assertThat(result.SATURDAY()).isFalse();
                softly.assertThat(result.SUNDAY()).isFalse();
            });
        }

        @Test
        void 학습_기록이_없으면_모두_false를_반환한다() {
            // given
            long userId = 1L;

            // when
            WeeklyLearningRecordResponse result = dailyLearningRecordService.getWeeklyLearningRecord(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.MONDAY()).isFalse();
                softly.assertThat(result.TUESDAY()).isFalse();
                softly.assertThat(result.WEDNESDAY()).isFalse();
                softly.assertThat(result.THURSDAY()).isFalse();
                softly.assertThat(result.FRIDAY()).isFalse();
                softly.assertThat(result.SATURDAY()).isFalse();
                softly.assertThat(result.SUNDAY()).isFalse();
            });
        }

        @Test
        void 다른_주차의_학습_기록은_무시된다() {
            // given
            long userId = 1L;
            LocalDate lastMonday = LocalDate.now(KST).with(DayOfWeek.MONDAY).minusWeeks(1);
            LocalDate nextMonday = LocalDate.now(KST).with(DayOfWeek.MONDAY).plusWeeks(1);
            dailyLearningRecordRepository.save(DailyLearningRecord.create(userId, lastMonday));
            dailyLearningRecordRepository.save(DailyLearningRecord.create(userId, nextMonday));

            // when
            WeeklyLearningRecordResponse result = dailyLearningRecordService.getWeeklyLearningRecord(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.MONDAY()).isFalse();
                softly.assertThat(result.TUESDAY()).isFalse();
                softly.assertThat(result.WEDNESDAY()).isFalse();
                softly.assertThat(result.THURSDAY()).isFalse();
                softly.assertThat(result.FRIDAY()).isFalse();
                softly.assertThat(result.SATURDAY()).isFalse();
                softly.assertThat(result.SUNDAY()).isFalse();
            });
        }

        @Test
        void 다른_사용자의_학습_기록은_무시된다() {
            // given
            long userId = 1L;
            long otherUserId = 2L;
            LocalDate monday = LocalDate.now(KST).with(DayOfWeek.MONDAY);
            dailyLearningRecordRepository.save(DailyLearningRecord.create(otherUserId, monday));

            // when
            WeeklyLearningRecordResponse result = dailyLearningRecordService.getWeeklyLearningRecord(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.MONDAY()).isFalse();
                softly.assertThat(result.TUESDAY()).isFalse();
                softly.assertThat(result.WEDNESDAY()).isFalse();
                softly.assertThat(result.THURSDAY()).isFalse();
                softly.assertThat(result.FRIDAY()).isFalse();
                softly.assertThat(result.SATURDAY()).isFalse();
                softly.assertThat(result.SUNDAY()).isFalse();
            });
        }
    }

    @Nested
    @DisplayName("일별 풀이 수를 연도별로 조회할 때")
    class GetDailySolvedCounts {

        @Test
        void 해당_연도의_학습_기록을_반환한다() {
            // given
            long userId = 1L;
            int year = LocalDate.now(KST).getYear();
            LocalDate today = LocalDate.now(KST);

            saveSolvedRecord(userId, today);
            saveSolvedRecord(userId, today.minusDays(1));

            // when
            List<DailySolvedCountResponse> result = dailyLearningRecordService.getDailySolvedCounts(userId, year);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result).extracting(DailySolvedCountResponse::solvedLessonCount)
                        .allMatch(count -> count == 1);
            });
        }

        @Test
        void 학습_기록이_없으면_빈_리스트를_반환한다() {
            // given
            long userId = 1L;
            int year = LocalDate.now(KST).getYear();

            // when
            List<DailySolvedCountResponse> result = dailyLearningRecordService.getDailySolvedCounts(userId, year);

            // then
            assertThat(result).isEmpty();
        }

        @Test
        void 다른_사용자의_학습_기록은_무시된다() {
            // given
            long userId = 1L;
            long otherUserId = 2L;
            int year = LocalDate.now(KST).getYear();
            dailyLearningRecordRepository.save(DailyLearningRecord.create(otherUserId, LocalDate.now(KST)));

            // when
            List<DailySolvedCountResponse> result = dailyLearningRecordService.getDailySolvedCounts(userId, year);

            // then
            assertThat(result).isEmpty();
        }

        @Test
        void 다른_연도의_학습_기록은_무시된다() {
            // given
            long userId = 1L;
            int year = LocalDate.now(KST).getYear();
            LocalDate lastYearDate = LocalDate.of(year - 1, 6, 1);
            dailyLearningRecordRepository.save(DailyLearningRecord.create(userId, lastYearDate));

            // when
            List<DailySolvedCountResponse> result = dailyLearningRecordService.getDailySolvedCounts(userId, year);

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("주간 학습 리포트를 조회할 때")
    class GetWeeklyLearningReport {

        @Test
        void 이번주_풀이_수와_지난주_대비_증감을_반환한다() {
            // given
            long userId = 1L;
            LocalDate thisMonday = LocalDate.now(KST).with(DayOfWeek.MONDAY);
            LocalDate lastMonday = thisMonday.minusWeeks(1);

            saveSolvedRecord(userId, thisMonday);
            saveSolvedRecord(userId, thisMonday.plusDays(2));
            saveSolvedRecord(userId, lastMonday);

            // when
            WeeklyLearningReportResponse result = dailyLearningRecordService.getWeeklyLearningReport(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.thisWeekCompletedLessonCount()).isEqualTo(2);
                softly.assertThat(result.weekOverWeekDeltas()).containsExactly(1, 2, 2);
                softly.assertThat(result.MONDAY()).isEqualTo(1);
                softly.assertThat(result.TUESDAY()).isZero();
                softly.assertThat(result.WEDNESDAY()).isEqualTo(1);
            });
        }

        @Test
        void 학습_기록이_없으면_모두_0을_반환한다() {
            // given
            long userId = 1L;

            // when
            WeeklyLearningReportResponse result = dailyLearningRecordService.getWeeklyLearningReport(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.thisWeekCompletedLessonCount()).isZero();
                softly.assertThat(result.weekOverWeekDeltas()).containsExactly(0, 0, 0);
                softly.assertThat(result.MONDAY()).isZero();
                softly.assertThat(result.SUNDAY()).isZero();
            });
        }

        @Test
        void 이번주만_학습했다면_지난주_대비_증감이_양수다() {
            // given
            long userId = 1L;
            LocalDate thisMonday = LocalDate.now(KST).with(DayOfWeek.MONDAY);
            saveSolvedRecord(userId, thisMonday);

            // when
            WeeklyLearningReportResponse result = dailyLearningRecordService.getWeeklyLearningReport(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.thisWeekCompletedLessonCount()).isEqualTo(1);
                softly.assertThat(result.weekOverWeekDeltas()).containsExactly(1, 1, 1);
            });
        }

        @Test
        void 지난주만_학습했다면_지난주_대비_증감이_음수다() {
            // given
            long userId = 1L;
            LocalDate lastMonday = LocalDate.now(KST).with(DayOfWeek.MONDAY).minusWeeks(1);
            saveSolvedRecord(userId, lastMonday);
            saveSolvedRecord(userId, lastMonday.plusDays(1));

            // when
            WeeklyLearningReportResponse result = dailyLearningRecordService.getWeeklyLearningReport(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.thisWeekCompletedLessonCount()).isZero();
                softly.assertThat(result.weekOverWeekDeltas()).containsExactly(-2, 0, 0);
            });
        }

        @Test
        void 이번주_풀이_수와_과거_3주_대비_증감을_분리해서_반환한다() {
            // given
            long userId = 1L;
            LocalDate thisMonday = LocalDate.now(KST).with(DayOfWeek.MONDAY);

            // 이번주 3개
            saveSolvedRecord(userId, thisMonday);
            saveSolvedRecord(userId, thisMonday.plusDays(1));
            saveSolvedRecord(userId, thisMonday.plusDays(2));
            // 저번주 2개
            saveSolvedRecord(userId, thisMonday.minusWeeks(1));
            saveSolvedRecord(userId, thisMonday.minusWeeks(1).plusDays(1));
            // 저저번주 0개
            // 저저저번주 1개
            saveSolvedRecord(userId, thisMonday.minusWeeks(3));

            // when
            WeeklyLearningReportResponse result = dailyLearningRecordService.getWeeklyLearningReport(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.thisWeekCompletedLessonCount()).isEqualTo(3);
                softly.assertThat(result.weekOverWeekDeltas()).containsExactly(1, 3, 2);
            });
        }

        @Test
        void 최근_4주보다_더_과거의_학습_기록은_무시된다() {
            // given
            long userId = 1L;
            LocalDate thisMonday = LocalDate.now(KST).with(DayOfWeek.MONDAY);

            dailyLearningRecordRepository.save(DailyLearningRecord.create(userId, thisMonday.minusWeeks(4)));
            dailyLearningRecordRepository.save(DailyLearningRecord.create(userId, thisMonday.minusWeeks(5)));

            // when
            WeeklyLearningReportResponse result = dailyLearningRecordService.getWeeklyLearningReport(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.thisWeekCompletedLessonCount()).isZero();
                softly.assertThat(result.weekOverWeekDeltas()).containsExactly(0, 0, 0);
            });
        }
    }

    @Nested
    @DisplayName("일일 학습 기록을 처리할 때")
    class HandleDailyLearningRecord {

        @Test
        void 오늘_날짜_레코드가_없으면_새로_생성하고_카운트가_1이_된다() {
            // given
            long userId = 1L;
            LocalDate today = LocalDate.now(KST);

            // when
            dailyLearningRecordService.handleDailyLearningRecord(userId);

            // then
            Optional<DailyLearningRecord> result = dailyLearningRecordRepository.findByUserIdAndSolvedDate(userId, today);
            assertSoftly(softly -> {
                softly.assertThat(result).isPresent();
                softly.assertThat(result.get().getUserId()).isEqualTo(userId);
                softly.assertThat(result.get().getSolvedDate()).isEqualTo(today);
                softly.assertThat(result.get().getSolvedLessonCount()).isEqualTo(1);
            });
        }

        @Test
        void 오늘_날짜_레코드가_존재하면_카운트가_1_증가한다() {
            // given
            long userId = 1L;
            LocalDate today = LocalDate.now(KST);
            DailyLearningRecord existing = DailyLearningRecord.create(userId, today);
            existing.increaseSolvedLessonCount();
            dailyLearningRecordRepository.save(existing);

            // when
            dailyLearningRecordService.handleDailyLearningRecord(userId);

            // then
            DailyLearningRecord result = dailyLearningRecordRepository.findByUserIdAndSolvedDate(userId, today).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(result.getId()).isEqualTo(existing.getId());
                softly.assertThat(result.getSolvedLessonCount()).isEqualTo(2);
                softly.assertThat(result.getSolvedDate()).isEqualTo(today);
            });
        }

        @Test
        void 같은_유저의_다른_날짜_레코드가_있어도_정상_처리된다() {
            // given
            long userId = 1L;
            LocalDate today = LocalDate.now(KST);
            LocalDate yesterday = today.minusDays(1);
            LocalDate twoDaysAgo = today.minusDays(2);

            DailyLearningRecord pastRecord1 = DailyLearningRecord.create(userId, yesterday);
            pastRecord1.increaseSolvedLessonCount();
            DailyLearningRecord pastRecord2 = DailyLearningRecord.create(userId, twoDaysAgo);
            pastRecord2.increaseSolvedLessonCount();
            dailyLearningRecordRepository.save(pastRecord1);
            dailyLearningRecordRepository.save(pastRecord2);

            // when & then
            assertThatCode(() -> dailyLearningRecordService.handleDailyLearningRecord(userId))
                    .doesNotThrowAnyException();

            DailyLearningRecord todayRecord = dailyLearningRecordRepository.findByUserIdAndSolvedDate(userId, today).orElseThrow();
            DailyLearningRecord yesterdayRecord = dailyLearningRecordRepository.findByUserIdAndSolvedDate(userId, yesterday).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(todayRecord.getSolvedLessonCount()).isEqualTo(1);
                softly.assertThat(yesterdayRecord.getSolvedLessonCount()).isEqualTo(1);
            });
        }

        @Test
        void 같은_메서드를_두_번_호출하면_카운트가_2가_된다() {
            // given
            long userId = 1L;
            LocalDate today = LocalDate.now(KST);

            // when
            dailyLearningRecordService.handleDailyLearningRecord(userId);
            dailyLearningRecordService.handleDailyLearningRecord(userId);

            // then
            DailyLearningRecord result = dailyLearningRecordRepository.findByUserIdAndSolvedDate(userId, today).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(result.getSolvedLessonCount()).isEqualTo(2);
                softly.assertThat(result.getUserId()).isEqualTo(userId);
                softly.assertThat(result.getSolvedDate()).isEqualTo(today);
            });
        }
    }
}
