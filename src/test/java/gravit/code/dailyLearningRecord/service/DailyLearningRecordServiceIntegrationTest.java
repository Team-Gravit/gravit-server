package gravit.code.dailyLearningRecord.service;

import gravit.code.dailyLearningRecord.domain.DailyLearningRecord;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningRecordResponse;
import gravit.code.dailyLearningRecord.repository.DailyLearningRecordRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;

import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class DailyLearningRecordServiceIntegrationTest {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    @Autowired
    private DailyLearningRecordService dailyLearningRecordService;

    @Autowired
    private DailyLearningRecordRepository dailyLearningRecordRepository;

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
}
