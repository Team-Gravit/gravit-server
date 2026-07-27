package gravit.code.mission.listener;

import gravit.code.dailyLearningRecord.service.DailyLearningRecordService;
import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.OnboardingCompletedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.learning.service.LearningCommandService;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.UserMission;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.mission.fixture.MissionFixture;
import gravit.code.mission.repository.MissionRepository;
import gravit.code.mission.repository.UserMissionRepository;
import gravit.code.mission.service.MissionService;
import gravit.code.support.TCSpringBootTest;
import gravit.code.userLeague.service.UserLeaguePointService;
import gravit.code.userLeague.service.UserLeagueService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.test.context.transaction.TestTransaction;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.after;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class MissionEventListenerIntegrationTest {

    @Autowired
    private ApplicationEventPublisher publisher;

    @Autowired
    private MissionRepository missionRepository;

    @Autowired
    private UserMissionRepository userMissionRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Autowired
    private Clock clock;

    @MockitoBean
    private RetryEventPublisher retryEventPublisher;

    @MockitoSpyBean
    private MissionService missionService;

    // 동일 이벤트를 AFTER_COMMIT으로 구독하는 다른 리스너의 실제 의존성 실행을 격리한다.
    @MockitoBean
    private UserLeaguePointService userLeaguePointService;

    @MockitoBean
    private DailyLearningRecordService dailyLearningRecordService;

    @MockitoBean
    private UserLeagueService userLeagueService;

    @MockitoBean
    private LearningCommandService learningCommandService;

    @Nested
    @DisplayName("레슨 완료 이벤트를 수신할 때")
    class HandleCompleteLessonMission {

        @Test
        @Transactional
        void 레슨_미션_처리_서비스를_호출하고_큐에_적재하지_않는다() {
            // given
            long userId = 1L;
            long lessonId = 10L;
            doNothing().when(missionService).handleLessonMission(userId, lessonId, 120, 80);

            LessonCompletedEvent event = new LessonCompletedEvent(userId, lessonId, 100L, 20, 80, 120, 0, 1);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(missionService, timeout(2000)).handleLessonMission(userId, lessonId, 120, 80);
            verify(retryEventPublisher, never()).publish(eq("mission-lesson-retry"), any());
        }

        @Test
        @Transactional
        void 레슨_미션_진행도를_별도_트랜잭션에서_실제로_커밋한다() {
            // given
            long userId = 1L;
            long lessonId = 10L;
            Mission mission = missionRepository.save(MissionFixture.미션정의_레슨_3개());
            userMissionRepository.save(MissionFixture.오늘_배정된_미션(userId, mission.getId(), LocalDate.now(clock)));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 80, lessonId, userId));

            LessonCompletedEvent event = new LessonCompletedEvent(userId, lessonId, 100L, 20, 80, 120, 0, 1);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(missionService, timeout(2000)).handleLessonMission(userId, lessonId, 120, 80);

            // REQUIRES_NEW가 아니면 AFTER_COMMIT 후속 쓰기가 커밋되지 않아 진행도가 0으로 유실된다
            UserMission committed = userMissionRepository.findAssignedMission(userId, LocalDate.now(clock))
                    .orElseThrow()
                    .userMission();
            assertThat(committed.getProgressCount()).isEqualTo(1);
            verify(retryEventPublisher, never()).publish(eq("mission-lesson-retry"), any());
        }

        @Test
        @Transactional
        void 미션이_존재하지_않으면_재시도_큐에_적재하지_않는다() {
            // given
            long nonExistentUserId = 999L;
            LessonCompletedEvent event = new LessonCompletedEvent(nonExistentUserId, 10L, 100L, 20, 80, 120, 0, 1);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, after(500).never()).publish(eq("mission-lesson-retry"), any());
        }

        @Test
        @Transactional
        void 일시적_오류가_발생하면_재시도_큐에_적재된다() {
            // given
            long userId = 1L;
            long lessonId = 10L;
            doThrow(new RuntimeException("DB 커넥션 실패"))
                    .when(missionService).handleLessonMission(userId, lessonId, 120, 80);

            LessonCompletedEvent event = new LessonCompletedEvent(userId, lessonId, 100L, 20, 80, 120, 0, 1);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, timeout(3000)).publish("mission-lesson-retry", Map.of(
                    "userId", String.valueOf(userId),
                    "lessonId", String.valueOf(lessonId),
                    "learningTime", "120",
                    "accuracy", "80"
            ));
        }
    }

    @Nested
    @DisplayName("팔로우 미션 이벤트를 수신할 때")
    class HandleFollowMission {

        @Test
        @Transactional
        void 팔로우_미션_처리_서비스를_호출하고_큐에_적재하지_않는다() {
            // given
            long userId = 1L;
            doNothing().when(missionService).handleFollowMission(new FollowMissionEvent(userId));

            // when
            publisher.publishEvent(new FollowMissionEvent(userId));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(missionService, timeout(2000)).handleFollowMission(new FollowMissionEvent(userId));
            verify(retryEventPublisher, never()).publish(eq("mission-follow-retry"), any());
        }

        @Test
        @Transactional
        void 미션이_존재하지_않으면_재시도_큐에_적재하지_않는다() {
            // given
            FollowMissionEvent event = new FollowMissionEvent(999L);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, after(500).never()).publish(eq("mission-follow-retry"), any());
        }

        @Test
        @Transactional
        void 일시적_오류가_발생하면_재시도_큐에_적재된다() {
            // given
            long userId = 1L;
            doThrow(new RuntimeException("DB 커넥션 실패"))
                    .when(missionService).handleFollowMission(new FollowMissionEvent(userId));

            // when
            publisher.publishEvent(new FollowMissionEvent(userId));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, timeout(3000)).publish("mission-follow-retry", Map.of(
                    "userId", String.valueOf(userId)
            ));
        }
    }

    @Nested
    @DisplayName("온보딩 완료 이벤트를 수신할 때")
    class CreateMission {

        @Test
        @Transactional
        void 오늘자_미션을_별도_트랜잭션에서_실제로_배정하고_큐에_적재하지_않는다() {
            // given
            long userId = 1L;
            missionRepository.save(MissionFixture.미션정의_레슨_1개());

            // when
            publisher.publishEvent(new OnboardingCompletedEvent(userId));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(missionService, timeout(2000)).createMission(userId);
            assertThat(userMissionRepository.findAssignedMission(userId, LocalDate.now(clock))).isPresent();
            verify(retryEventPublisher, never()).publish(eq("mission-create-retry"), any());
        }

        @Test
        @Transactional
        void 일시적_오류가_발생하면_재시도_큐에_적재된다() {
            // given
            long userId = 1L;
            doThrow(new RuntimeException("DB 커넥션 실패")).when(missionService).createMission(userId);

            // when
            publisher.publishEvent(new OnboardingCompletedEvent(userId));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, timeout(3000)).publish("mission-create-retry", Map.of(
                    "userId", String.valueOf(userId)
            ));
        }
    }
}
