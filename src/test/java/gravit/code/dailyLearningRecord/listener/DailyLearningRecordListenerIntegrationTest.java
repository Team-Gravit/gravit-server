package gravit.code.dailyLearningRecord.listener;

import gravit.code.dailyLearningRecord.domain.DailyLearningRecord;
import gravit.code.dailyLearningRecord.repository.DailyLearningRecordRepository;
import gravit.code.dailyLearningRecord.service.DailyLearningRecordService;
import gravit.code.global.consts.TimeZoneConst;
import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.mission.service.MissionService;
import gravit.code.support.TCSpringBootTest;
import gravit.code.userLeague.service.UserLeaguePointService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.test.context.transaction.TestTransaction;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Map;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class DailyLearningRecordListenerIntegrationTest {

    @Autowired
    private ApplicationEventPublisher publisher;

    @Autowired
    private DailyLearningRecordRepository dailyLearningRecordRepository;

    @MockitoBean
    private RetryEventPublisher retryEventPublisher;

    @MockitoSpyBean
    private DailyLearningRecordService dailyLearningRecordService;

    // 동일 LessonCompletedEvent를 AFTER_COMMIT으로 구독하는 다른 리스너의 실제 의존성 실행을 격리한다.
    @MockitoBean
    private UserLeaguePointService userLeaguePointService;

    @MockitoBean
    private MissionService missionService;

    @Nested
    @DisplayName("레슨 완료 이벤트가 발행되면")
    class HandleDailyLearningRecord {

        @Test
        @Transactional
        void 트랜잭션_커밋_후_일일_학습_기록을_별도_트랜잭션에서_실제로_커밋하고_큐에_적재하지_않는다() {
            // given
            long userId = 1L;

            LessonCompletedEvent event = new LessonCompletedEvent(userId, 10L, 100L, 20, 80, 120, 0, 1);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(dailyLearningRecordService, timeout(2000)).handleDailyLearningRecord(userId);

            Optional<DailyLearningRecord> record = dailyLearningRecordRepository
                    .findByUserIdAndSolvedDate(userId, LocalDate.now(TimeZoneConst.KST));
            assertThat(record).isPresent();
            assertThat(record.get().getSolvedLessonCount()).isEqualTo(1);

            verify(retryEventPublisher, never()).publish(eq("daily-learning-record-retry"), any());
        }

        @Test
        @Transactional
        void 일시적_오류가_발생하면_재시도_큐에_적재된다() {
            // given
            long userId = 1L;
            doThrow(new RuntimeException("DB 커넥션 실패")).when(dailyLearningRecordService).handleDailyLearningRecord(userId);

            LessonCompletedEvent event = new LessonCompletedEvent(userId, 10L, 100L, 20, 80, 120, 0, 1);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, timeout(3000)).publish("daily-learning-record-retry", Map.of(
                    "userId", String.valueOf(userId)
            ));
        }
    }
}
