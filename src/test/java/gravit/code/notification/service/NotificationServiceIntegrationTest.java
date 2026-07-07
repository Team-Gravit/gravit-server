package gravit.code.notification.service;

import gravit.code.notification.domain.Notification;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.repository.NotificationRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@TCSpringBootTest
class NotificationServiceIntegrationTest {

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private UserRepository userRepository;

    @Nested
    @DisplayName("전체 유저에게 알림을 적재할 때")
    class NotifyAllUsers {

        @Test
        void 활성_유저_전원에게_적재하고_탈퇴_유저는_제외한다() {
            // given
            User user1 = userRepository.save(User.create("a@test.com", "p1", "유저1", "h1", 1, Role.USER));
            User user2 = userRepository.save(User.create("b@test.com", "p2", "유저2", "h2", 1, Role.USER));
            User deleted = userRepository.save(User.create("c@test.com", "p3", "유저3", "h3", 1, Role.USER));
            userRepository.delete(deleted); // soft delete (deleted_at 설정)

            // when
            notificationService.notifyAllUsers(NotificationType.NOTICE, "[공지] 점검 안내", null, 99L);

            // then
            List<Notification> notifications = notificationRepository.findAll();
            assertThat(notifications)
                    .extracting(Notification::getUserId)
                    .containsExactlyInAnyOrder(user1.getId(), user2.getId());
            assertThat(notifications).allSatisfy(notification -> {
                assertThat(notification.getType()).isEqualTo(NotificationType.NOTICE);
                assertThat(notification.getMessage()).isEqualTo("[공지] 점검 안내");
                assertThat(notification.getTargetId()).isEqualTo(99L);
                assertThat(notification.isRead()).isFalse();
            });
        }

        @Test
        void 활성_유저가_없으면_아무것도_적재하지_않는다() {
            // when
            notificationService.notifyAllUsers(NotificationType.NOTICE, "[공지] 점검 안내", null, 1L);

            // then
            assertThat(notificationRepository.findAll()).isEmpty();
        }

        @Test
        void 서브텍스트가_함께_적재된다() {
            // given
            userRepository.save(User.create("a@test.com", "p1", "유저1", "h1", 1, Role.USER));

            // when - 헤드라인 + 서브텍스트
            notificationService.notifyAllUsers(NotificationType.NOTICE, "새로운 공지사항이 있어요", "정기 점검 안내", 99L);

            // then
            assertThat(notificationRepository.findAll())
                    .singleElement()
                    .satisfies(n -> {
                        assertThat(n.getMessage()).isEqualTo("새로운 공지사항이 있어요");
                        assertThat(n.getSubText()).isEqualTo("정기 점검 안내");
                    });
        }
    }

    @Nested
    @DisplayName("특정 유저 목록에게 알림을 적재할 때")
    class NotifyUsers {

        @Test
        void 목록의_유저_모두에게_알림이_적재된다() {
            // given
            User user1 = userRepository.save(User.create("a@test.com", "p1", "유저1", "h1", 1, Role.USER));
            User user2 = userRepository.save(User.create("b@test.com", "p2", "유저2", "h2", 1, Role.USER));
            userRepository.save(User.create("c@test.com", "p3", "유저3", "h3", 1, Role.USER)); // 대상 외 유저

            // when
            notificationService.notifyUsers(
                    List.of(user1.getId(), user2.getId()),
                    NotificationType.FRIEND_ACTIVITY,
                    "유저3님이 LV.5이 됐어요! 💪"
            );

            // then
            List<Notification> notifications = notificationRepository.findAll();
            assertThat(notifications)
                    .extracting(Notification::getUserId)
                    .containsExactlyInAnyOrder(user1.getId(), user2.getId());
            assertThat(notifications).allSatisfy(n -> {
                assertThat(n.getType()).isEqualTo(NotificationType.FRIEND_ACTIVITY);
                assertThat(n.getMessage()).isEqualTo("유저3님이 LV.5이 됐어요! 💪");
                assertThat(n.isRead()).isFalse();
            });
        }

        @Test
        void 빈_목록이면_아무것도_적재하지_않는다() {
            // when
            notificationService.notifyUsers(List.of(), NotificationType.FRIEND_ACTIVITY, "테스트");

            // then
            assertThat(notificationRepository.findAll()).isEmpty();
        }
    }
}
