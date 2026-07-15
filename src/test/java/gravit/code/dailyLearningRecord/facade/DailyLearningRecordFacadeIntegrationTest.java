package gravit.code.dailyLearningRecord.facade;

import gravit.code.dailyLearningRecord.domain.DailyLearningRecord;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningRecordResponse;
import gravit.code.dailyLearningRecord.repository.DailyLearningRecordRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.repository.LearningRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;

import static gravit.code.global.exception.domain.CustomErrorCode.LEARNING_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class DailyLearningRecordFacadeIntegrationTest {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    @Autowired
    private DailyLearningRecordFacade dailyLearningRecordFacade;

    @Autowired
    private DailyLearningRecordRepository dailyLearningRecordRepository;

    @Autowired
    private LearningRepository learningRepository;

    private Learning saveLearningWithConsecutiveDays(long userId, int consecutiveSolvedDays) {
        Learning learning = Learning.create(userId);
        ReflectionTestUtils.setField(learning, "consecutiveSolvedDays", consecutiveSolvedDays);
        return learningRepository.save(learning);
    }

    @Nested
    @DisplayName("주간 학습 기록을 조회할 때")
    class GetWeeklyLearningRecord {

        @Test
        void 연속_학습일과_학습한_요일을_함께_반환한다() {
            // given
            long userId = 1L;
            saveLearningWithConsecutiveDays(userId, 7);

            LocalDate monday = LocalDate.now(KST).with(DayOfWeek.MONDAY);
            dailyLearningRecordRepository.save(DailyLearningRecord.create(userId, monday));
            dailyLearningRecordRepository.save(DailyLearningRecord.create(userId, monday.plusDays(2)));

            // when
            WeeklyLearningRecordResponse result = dailyLearningRecordFacade.getWeeklyLearningRecord(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.consecutiveSolvedDays()).isEqualTo(7);
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
        void 학습한_요일이_없어도_연속_학습일은_반환한다() {
            // given
            long userId = 1L;
            saveLearningWithConsecutiveDays(userId, 3);

            // when
            WeeklyLearningRecordResponse result = dailyLearningRecordFacade.getWeeklyLearningRecord(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.consecutiveSolvedDays()).isEqualTo(3);
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
        void 학습_정보가_없으면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> dailyLearningRecordFacade.getWeeklyLearningRecord(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LEARNING_NOT_FOUND);
        }
    }
}
