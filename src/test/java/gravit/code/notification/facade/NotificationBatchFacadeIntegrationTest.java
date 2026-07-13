package gravit.code.notification.facade;

import gravit.code.fcm.domain.FcmToken;
import gravit.code.fcm.domain.Platform;
import gravit.code.fcm.dto.internal.PushMessage;
import gravit.code.fcm.repository.FcmTokenRepository;
import gravit.code.fcm.service.FcmService;
import gravit.code.learning.dto.internal.ConsecutiveAtRiskUser;
import gravit.code.learning.service.LearningQueryService;
import gravit.code.notification.domain.Notification;
import gravit.code.notification.domain.NotificationActionType;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.repository.NotificationRepository;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.service.UserAccessService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.time.Clock;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@TCSpringBootTest
class NotificationBatchFacadeIntegrationTest {

    @Autowired
    private NotificationBatchFacade notificationBatchFacade;

    @Autowired
    private NotificationMessageProvider messageProvider;

    @Autowired
    private Clock clock; // FixedClockConfig: 2025-08-05T12:00+09:00 고정

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private FcmTokenRepository fcmTokenRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private SeasonFixture seasonFixture;

    // 대상 유저 선정 로직은 격리하고, 알림 적재·푸시 구성은 실제로 동작시킨다
    @MockitoBean
    private LearningQueryService learningQueryService;

    @MockitoBean
    private UserAccessService userAccessService;

    // FCM 외부 발송 경계만 격리하고, 토큰 조회·메시지 구성 등 우리 로직은 실제로 동작시킨다
    @MockitoBean
    private FcmService fcmService;

    // 전체 발송 대상이 될 안드로이드 FCM 토큰을 사전에 적재한다 (웹 푸시 미지원이므로 ANDROID만 푸시 대상)
    private List<String> 토큰_2개_준비() {
        User user1 = userFixture.일반_유저(1);
        User user2 = userFixture.일반_유저(2);
        fcmTokenRepository.save(FcmToken.create(user1.getId(), "device-1", "token-1", Platform.ANDROID));
        fcmTokenRepository.save(FcmToken.create(user2.getId(), "device-2", "token-2", Platform.ANDROID));
        return List.of("token-1", "token-2");
    }

    private String 종료_임박_헤드라인(int daysBefore) {
        return messageProvider.seasonEndingMilestones().stream()
                .filter(milestone -> milestone.daysBefore() == daysBefore)
                .findFirst()
                .orElseThrow()
                .headline();
    }

    @SuppressWarnings("unchecked")
    private List<PushMessage> 발송된_메시지_캡처(int timeoutMillis) {
        ArgumentCaptor<List<PushMessage>> captor = ArgumentCaptor.forClass(List.class);
        verify(fcmService, timeout(timeoutMillis)).sendNotifications(captor.capture());
        return captor.getValue();
    }

    @Nested
    @DisplayName("3.1 연속학습 끊길 위기")
    class ConsecutiveLearningWarning {

        @Test
        void 유저별_헤드라인과_공통_서브텍스트로_인앱_적재하고_안드로이드_토큰만_푸시한다() {
            // given - u1만 안드로이드 토큰 보유
            User u1 = userFixture.일반_유저(1);
            User u2 = userFixture.일반_유저(2);
            fcmTokenRepository.save(FcmToken.create(u1.getId(), "device-1", "token-1", Platform.ANDROID));
            when(learningQueryService.getConsecutiveAtRiskUsers()).thenReturn(List.of(
                    new ConsecutiveAtRiskUser(u1.getId(), 3),
                    new ConsecutiveAtRiskUser(u2.getId(), 5)
            ));

            // when
            notificationBatchFacade.sendConsecutiveLearningWarnings();

            // then - 인앱: 2명 모두 적재(개인화 헤드라인 + 공통 서브텍스트)
            List<Notification> saved = notificationRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(2);
                softly.assertThat(saved).allMatch(n -> n.getType() == NotificationType.CONSECUTIVE_LEARNING_WARNING);
                softly.assertThat(saved).allMatch(n -> n.getSubText().equals(messageProvider.consecutiveWarningSubText()));
                softly.assertThat(saved).extracting(Notification::getMessage)
                        .containsExactlyInAnyOrder("3일 연속학습이 끊길 위기예요!", "5일 연속학습이 끊길 위기예요!");
            });
            // 푸시: 토큰을 가진 u1만 대상
            List<PushMessage> sent = 발송된_메시지_캡처(1000);
            assertSoftly(softly -> {
                softly.assertThat(sent).hasSize(1);
                softly.assertThat(sent.get(0).tokens()).containsExactly("token-1");
                softly.assertThat(sent.get(0).title()).isEqualTo("3일 연속학습이 끊길 위기예요!");
            });
        }

        @Test
        void 대상이_없으면_인앱_적재도_푸시도_하지_않는다() {
            // given
            when(learningQueryService.getConsecutiveAtRiskUsers()).thenReturn(List.of());

            // when
            notificationBatchFacade.sendConsecutiveLearningWarnings();

            // then
            assertThat(notificationRepository.findAll()).isEmpty();
            verify(fcmService, never()).sendNotifications(anyList());
        }
    }

    @Nested
    @DisplayName("3.2 오늘 학습 미완료")
    class DailyIncomplete {

        @Test
        void 랜덤_문구로_인앱_적재하고_안드로이드_토큰만_푸시한다() {
            // given
            User u1 = userFixture.일반_유저(1);
            User u2 = userFixture.일반_유저(2);
            fcmTokenRepository.save(FcmToken.create(u1.getId(), "device-1", "token-1", Platform.ANDROID));
            when(learningQueryService.getDailyIncompleteUserIds()).thenReturn(List.of(u1.getId(), u2.getId()));

            // when
            notificationBatchFacade.sendDailyIncompleteReminders();

            // then - 인앱 2건, 서브텍스트 없음, 문구는 정의된 랜덤 문구 중 하나
            List<String> 가능한_문구 = List.of(
                    "오늘 아직 학습을 안 했어요! 10분만 투자해보세요 📚",
                    "오늘 학습을 시작해보세요! 작은 습관이 큰 변화를 만들어요 🌱",
                    "지금 이 시간에도 누군가는 CS를 공부하고 있어요 👀"
            );
            List<Notification> saved = notificationRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(2);
                softly.assertThat(saved).allMatch(n -> n.getType() == NotificationType.DAILY_INCOMPLETE);
                softly.assertThat(saved).allMatch(n -> n.getSubText() == null);
                softly.assertThat(saved).allMatch(n -> 가능한_문구.contains(n.getMessage()));
            });
            // 푸시: u1만
            List<PushMessage> sent = 발송된_메시지_캡처(1000);
            assertThat(sent).hasSize(1);
            assertThat(sent.get(0).tokens()).containsExactly("token-1");
        }
    }

    @Nested
    @DisplayName("3.3 장기 미접속")
    class Inactivity {

        @Test
        void 마일스톤_문구로_인앱_적재하고_안드로이드_토큰만_푸시한다() {
            // given - 7일 마일스톤에만 대상 존재
            User u1 = userFixture.일반_유저(1);
            fcmTokenRepository.save(FcmToken.create(u1.getId(), "device-1", "token-1", Platform.ANDROID));
            when(userAccessService.getUserIdsInactiveForExactly(7)).thenReturn(List.of(u1.getId()));
            when(userAccessService.getUserIdsInactiveForExactly(14)).thenReturn(List.of());
            when(userAccessService.getUserIdsInactiveForExactly(30)).thenReturn(List.of());

            // when
            notificationBatchFacade.sendInactivityReminders();

            // then - 인앱 1건(7일 문구)
            List<Notification> saved = notificationRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(1);
                softly.assertThat(saved.get(0).getType()).isEqualTo(NotificationType.INACTIVITY);
                softly.assertThat(saved.get(0).getMessage()).isEqualTo("벌써 일주일이 지났어요 😢 Gravit이 기다리고 있어요!");
            });
            // 푸시: u1
            List<PushMessage> sent = 발송된_메시지_캡처(1000);
            assertThat(sent).hasSize(1);
            assertThat(sent.get(0).tokens()).containsExactly("token-1");
        }

        @Test
        void 어떤_마일스톤에도_대상이_없으면_아무것도_하지_않는다() {
            // given
            when(userAccessService.getUserIdsInactiveForExactly(7)).thenReturn(List.of());
            when(userAccessService.getUserIdsInactiveForExactly(14)).thenReturn(List.of());
            when(userAccessService.getUserIdsInactiveForExactly(30)).thenReturn(List.of());

            // when
            notificationBatchFacade.sendInactivityReminders();

            // then
            assertThat(notificationRepository.findAll()).isEmpty();
            verify(fcmService, never()).sendNotifications(anyList());
        }
    }

    @Nested
    @DisplayName("시즌 종료 임박 알림을 발송할 때")
    class SendSeasonEndingReminders {

        @Test
        void 종료_7일_전이면_일주일_문구를_전체_발송한다() {
            // given
            LocalDate today = LocalDate.now(clock);
            seasonFixture.진행중인_시즌("2025-S2",
                    today.minusMonths(4).atStartOfDay(),
                    today.plusDays(7).atStartOfDay());
            List<String> tokens = 토큰_2개_준비();

            // when
            notificationBatchFacade.sendSeasonEndingReminders();

            // then - FCM 발송 (헤드라인)
            List<PushMessage> sent = 발송된_메시지_캡처(1000);
            assertSoftly(softly -> {
                softly.assertThat(sent).hasSize(1);
                softly.assertThat(sent.get(0).tokens()).containsExactlyInAnyOrderElementsOf(tokens);
                softly.assertThat(sent.get(0).title()).isEqualTo(종료_임박_헤드라인(7));
                softly.assertThat(sent.get(0).data())
                        .containsEntry("type", NotificationType.SEASON_ENDING.name())
                        .containsEntry("actionType", NotificationActionType.GO_TO_LEARNING.name());
            });
            // DB 저장 - 토큰을 가진 2명 모두 알림함에 적재 (헤드라인 + 서브텍스트)
            List<Notification> saved = notificationRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(2);
                softly.assertThat(saved).allMatch(n -> n.getType() == NotificationType.SEASON_ENDING);
                softly.assertThat(saved).allMatch(n -> n.getMessage().equals(종료_임박_헤드라인(7)));
                softly.assertThat(saved).allMatch(n -> n.getSubText() != null);
            });
        }

        @Test
        void 종료_3일_전이면_3일_문구를_전체_발송한다() {
            // given
            LocalDate today = LocalDate.now(clock);
            seasonFixture.진행중인_시즌("2025-S2",
                    today.minusMonths(4).atStartOfDay(),
                    today.plusDays(3).atStartOfDay());
            토큰_2개_준비();

            // when
            notificationBatchFacade.sendSeasonEndingReminders();

            // then - FCM 발송
            List<PushMessage> sent = 발송된_메시지_캡처(1000);
            assertSoftly(softly -> {
                softly.assertThat(sent.get(0).title()).isEqualTo(종료_임박_헤드라인(3));
                softly.assertThat(sent.get(0).data())
                        .containsEntry("type", NotificationType.SEASON_ENDING.name());
            });
            // DB 저장
            assertThat(notificationRepository.findAll()).hasSize(2);
        }

        @Test
        void 마일스톤_일수가_아니면_발송하지_않는다() {
            // given (5일 전 - 7/3 어디에도 해당하지 않음)
            LocalDate today = LocalDate.now(clock);
            seasonFixture.진행중인_시즌("2025-S2",
                    today.minusMonths(4).atStartOfDay(),
                    today.plusDays(5).atStartOfDay());
            토큰_2개_준비();

            // when
            notificationBatchFacade.sendSeasonEndingReminders();

            // then
            verify(fcmService, never()).sendNotifications(anyList());
            assertThat(notificationRepository.findAll()).isEmpty();
        }

        @Test
        void ACTIVE_시즌이_없으면_발송하지_않는다() {
            // given - 시즌 미생성
            토큰_2개_준비();

            // when
            notificationBatchFacade.sendSeasonEndingReminders();

            // then
            verify(fcmService, never()).sendNotifications(anyList());
            assertThat(notificationRepository.findAll()).isEmpty();
        }
    }

    @Nested
    @DisplayName("시즌 종료+새 시즌 알림(오전 9시 스케줄)을 발송할 때")
    class SendSeasonResetAlerts {

        @Test
        void ACTIVE_시즌_시작일이_오늘이면_전체_발송한다() {
            // given - 직전 자정에 롤오버되어 오늘 시작된 ACTIVE 시즌
            LocalDate today = LocalDate.now(clock);
            seasonFixture.진행중인_시즌("2025-S2",
                    today.atStartOfDay(),
                    today.plusMonths(4).atStartOfDay());
            List<String> tokens = 토큰_2개_준비();

            // when
            notificationBatchFacade.sendSeasonResetAlerts();

            // then - FCM 발송
            List<PushMessage> sent = 발송된_메시지_캡처(1000);
            assertSoftly(softly -> {
                softly.assertThat(sent).hasSize(1);
                softly.assertThat(sent.get(0).tokens()).containsExactlyInAnyOrderElementsOf(tokens);
                softly.assertThat(sent.get(0).title()).isEqualTo(messageProvider.seasonReset());
                softly.assertThat(sent.get(0).data())
                        .containsEntry("type", NotificationType.SEASON_RESET.name())
                        .containsEntry("actionType", NotificationActionType.NONE.name());
            });
            // DB 저장 - 2명 모두 알림함에 적재
            List<Notification> saved = notificationRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(2);
                softly.assertThat(saved).allMatch(n -> n.getType() == NotificationType.SEASON_RESET);
                softly.assertThat(saved).allMatch(n -> n.getMessage().equals(messageProvider.seasonReset()));
            });
        }

        @Test
        void ACTIVE_시즌_시작일이_오늘이_아니면_발송하지_않는다() {
            // given - 과거에 시작된 ACTIVE 시즌 (오늘 롤오버가 아님)
            LocalDate today = LocalDate.now(clock);
            seasonFixture.진행중인_시즌("2025-S2",
                    today.minusMonths(2).atStartOfDay(),
                    today.plusMonths(2).atStartOfDay());
            토큰_2개_준비();

            // when
            notificationBatchFacade.sendSeasonResetAlerts();

            // then
            verify(fcmService, never()).sendNotifications(anyList());
            assertThat(notificationRepository.findAll()).isEmpty();
        }

        @Test
        void ACTIVE_시즌이_없으면_발송하지_않는다() {
            // given - 시즌 미생성
            토큰_2개_준비();

            // when
            notificationBatchFacade.sendSeasonResetAlerts();

            // then
            verify(fcmService, never()).sendNotifications(anyList());
            assertThat(notificationRepository.findAll()).isEmpty();
        }
    }
}
