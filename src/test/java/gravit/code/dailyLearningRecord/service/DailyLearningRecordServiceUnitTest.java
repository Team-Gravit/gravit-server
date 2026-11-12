package gravit.code.dailyLearningRecord.service;

import gravit.code.dailyLearningRecord.domain.DailyLearningRecord;
import gravit.code.dailyLearningRecord.repository.DailyLearningRecordRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Optional;

import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DailyLearningRecordServiceUnitTest {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    @InjectMocks
    private DailyLearningRecordService dailyLearningRecordService;

    @Mock
    private DailyLearningRecordRepository dailyLearningRecordRepository;

    @Nested
    @DisplayName("일일 학습 기록을 처리할 때")
    class HandleDailyLearningRecord {

        @Test
        void 오늘_날짜_레코드가_존재하면_카운트가_1_증가한다() {
            // given
            long userId = 1L;
            LocalDate today = LocalDate.now(KST);
            DailyLearningRecord existing = DailyLearningRecord.create(userId, today);
            existing.increaseSolvedLessonCount();

            when(dailyLearningRecordRepository.findByUserIdAndSolvedDate(userId, today))
                    .thenReturn(Optional.of(existing));

            // when
            dailyLearningRecordService.handleDailyLearningRecord(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(existing.getSolvedLessonCount()).isEqualTo(2);
                softly.assertThat(existing.getUserId()).isEqualTo(userId);
                softly.assertThat(existing.getSolvedDate()).isEqualTo(today);
            });
            verify(dailyLearningRecordRepository).save(existing);
        }

        @Test
        void 오늘_날짜_레코드가_없으면_새로_생성하고_카운트가_1이_된다() {
            // given
            long userId = 1L;
            LocalDate today = LocalDate.now(KST);

            when(dailyLearningRecordRepository.findByUserIdAndSolvedDate(userId, today))
                    .thenReturn(Optional.empty());

            // when
            dailyLearningRecordService.handleDailyLearningRecord(userId);

            // then
            ArgumentCaptor<DailyLearningRecord> captor = ArgumentCaptor.forClass(DailyLearningRecord.class);
            verify(dailyLearningRecordRepository).save(captor.capture());

            DailyLearningRecord saved = captor.getValue();
            assertSoftly(softly -> {
                softly.assertThat(saved.getUserId()).isEqualTo(userId);
                softly.assertThat(saved.getSolvedDate()).isEqualTo(today);
                softly.assertThat(saved.getSolvedLessonCount()).isEqualTo(1);
            });
        }

        @Test
        void 오늘_날짜를_조건으로_조회한다() {
            // given
            long userId = 1L;
            LocalDate today = LocalDate.now(KST);

            when(dailyLearningRecordRepository.findByUserIdAndSolvedDate(userId, today))
                    .thenReturn(Optional.empty());

            // when
            dailyLearningRecordService.handleDailyLearningRecord(userId);

            // then
            verify(dailyLearningRecordRepository).findByUserIdAndSolvedDate(userId, today);
        }
    }
}
