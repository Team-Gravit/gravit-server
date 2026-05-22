package gravit.code.dailyLearningRecord.listener;

import gravit.code.dailyLearningRecord.service.DailyLearningRecordService;
import gravit.code.global.event.LessonCompletedEvent;
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

import java.util.concurrent.TimeUnit;

import static org.awaitility.Awaitility.await;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class DailyLearningRecordListenerIntegrationTest {

    @Autowired
    private ApplicationEventPublisher publisher;

    @MockitoSpyBean
    private DailyLearningRecordService dailyLearningRecordService;

    // 같은 LessonCompletedEvent를 BEFORE_COMMIT으로 구독하는 다른 리스너의 의존성을 격리한다.
    // - UserLeagueEventListener: try-catch 없음 → 예외 전파로 트랜잭션 롤백
    // - MissionEventListener: try-catch 있지만 내부 @Transactional이 본 트랜잭션을 rollback-only로 마크
    @MockitoBean
    private UserLeaguePointService userLeaguePointService;

    @MockitoBean
    private MissionService missionService;

    @Nested
    @DisplayName("레슨 완료 이벤트가 발행되면")
    class HandleDailyLearningRecord {

        @Test
        @Transactional
        void 트랜잭션_커밋_후_비동기로_서비스의_일일_학습_기록_처리_메서드가_호출된다() {
            // given
            long userId = 1L;
            LessonCompletedEvent event = new LessonCompletedEvent(userId, 10L, 100L, 20, 80, 120, 0, 1);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            await().atMost(2, TimeUnit.SECONDS).untilAsserted(() ->
                    verify(dailyLearningRecordService).handleDailyLearningRecord(userId)
            );
        }
    }
}
