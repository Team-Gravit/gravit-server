package gravit.code.notification.facade;

import gravit.code.fcm.domain.FcmToken;
import gravit.code.fcm.domain.Platform;
import gravit.code.fcm.repository.FcmTokenRepository;
import gravit.code.fcm.service.FcmService;
import gravit.code.notification.domain.Notification;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.repository.NotificationRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class NotificationFacadeIntegrationTest {

    @Autowired
    private NotificationFacade notificationFacade;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private FcmTokenRepository fcmTokenRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    // FCM 외부 발송 경계만 격리하고, 토큰 조회·메시지 구성 등 우리 로직은 실제로 동작시킨다
    @MockitoBean
    private FcmService fcmService;

    @Nested
    @DisplayName("단일 유저에게 알림을 발송할 때(인앱+푸시)")
    class NotifyUser {

        @Test
        void 인앱_알림이_저장되고_FCM이_발송된다() {
            // given
            User user = userFixture.일반_유저(1);
            fcmTokenRepository.save(FcmToken.create(user.getId(), "device-1", "token-1", Platform.ANDROID));

            // when
            notificationFacade.notifyUser(user.getId(), NotificationType.INQUIRY_ANSWERED, "문의하신 내용에 답변이 등록되었어요", 1L);

            // then - DB 저장
            List<Notification> saved = notificationRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(1);
                softly.assertThat(saved.get(0).getUserId()).isEqualTo(user.getId());
                softly.assertThat(saved.get(0).getType()).isEqualTo(NotificationType.INQUIRY_ANSWERED);
                softly.assertThat(saved.get(0).isRead()).isFalse();
            });
            // FCM 발송
            verify(fcmService, timeout(1000)).sendNotifications(anyList());
        }

        @Test
        void FCM_토큰이_없어도_인앱_알림은_저장된다() {
            // given - 토큰 미등록
            User user = userFixture.일반_유저(1);

            // when
            notificationFacade.notifyUser(user.getId(), NotificationType.INQUIRY_ANSWERED, "문의하신 내용에 답변이 등록되었어요", 1L);

            // then - DB 저장
            assertThat(notificationRepository.findAll()).hasSize(1);
            // FCM 미발송
            verify(fcmService, never()).sendNotifications(anyList());
        }
    }

    @Nested
    @DisplayName("인앱 전용 알림을 발송할 때(푸시 미발송)")
    class NotifyInApp {

        @Test
        void 팔로우_알림은_인앱에만_저장되고_FCM은_발송되지_않는다() {
            // given
            User receiver = userFixture.일반_유저(1);
            fcmTokenRepository.save(FcmToken.create(receiver.getId(), "device-1", "token-1", Platform.ANDROID));
            long followerId = 42L;

            // when
            notificationFacade.notifyUserInApp(receiver.getId(), NotificationType.FOLLOW, "유저42님이 나를 팔로우했어요! 👀", followerId);

            // then - DB 저장 (targetId 포함)
            List<Notification> saved = notificationRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(1);
                softly.assertThat(saved.get(0).getType()).isEqualTo(NotificationType.FOLLOW);
                softly.assertThat(saved.get(0).getTargetId()).isEqualTo(followerId);
            });
            // FCM 미발송
            verify(fcmService, never()).sendNotifications(anyList());
        }

        @Test
        void 친구활동_알림은_여러_유저_인앱에만_저장된다() {
            // given
            User user1 = userFixture.일반_유저(1);
            User user2 = userFixture.일반_유저(2);
            long feedId = 99L;

            // when
            notificationFacade.notifyUsersInApp(
                    List.of(user1.getId(), user2.getId()),
                    NotificationType.FRIEND_ACTIVITY,
                    "유저3님이 OS행성을 정복했어요! 🌍",
                    feedId
            );

            // then
            List<Notification> saved = notificationRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(2);
                softly.assertThat(saved).allMatch(n -> n.getType() == NotificationType.FRIEND_ACTIVITY);
                softly.assertThat(saved).allMatch(n -> feedId == n.getTargetId());
            });
            verify(fcmService, never()).sendNotifications(anyList());
        }
    }
}
