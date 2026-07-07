package gravit.code.notification.listener;

import gravit.code.global.event.FollowedEvent;
import gravit.code.global.event.NoticeCreatedEvent;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.facade.NotificationFacade;
import gravit.code.notification.service.NotificationService;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.service.UserService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.transaction.TestTransaction;
import org.springframework.transaction.annotation.Transactional;

import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@TCSpringBootTest
class NotificationEventListenerIntegrationTest {

    @Autowired
    private ApplicationEventPublisher publisher;

    @Autowired
    private NotificationMessageProvider messageProvider;

    @MockitoBean
    private NotificationService notificationService;

    @MockitoBean
    private NotificationFacade notificationFacade;

    @MockitoBean
    private UserService userService;

    @Nested
    @DisplayName("공지 생성 이벤트를 처리할 때")
    class HandleNoticeCreated {

        @Test
        @Transactional
        @DisplayName("헤드라인은 고정, 공지 제목은 서브텍스트로 전체 적재를 위임한다")
        void 헤드라인_고정_제목_서브텍스트로_위임한다() {
            // when
            publisher.publishEvent(new NoticeCreatedEvent(10L, "정기 점검 안내"));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(notificationService, timeout(3000)).notifyAllUsers(
                    NotificationType.NOTICE,
                    "새로운 공지사항이 있어요",
                    "정기 점검 안내",
                    10L
            );
        }
    }

    @Nested
    @DisplayName("팔로우 이벤트를 처리할 때")
    class HandleFollowed {

        @Test
        @Transactional
        @DisplayName("인앱 전용(notifyUserInApp)으로 위임하고 푸시는 보내지 않는다")
        void 인앱_전용으로_위임한다() {
            // given - 팔로워(2)가 팔로위(1)를 팔로우
            User follower = User.create("u2@test.com", "p2", "유저2", "h2", 1, Role.USER);
            when(userService.getUser(2L)).thenReturn(follower);

            // when
            publisher.publishEvent(new FollowedEvent(2L, 1L));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then - 인앱 전용 적재로 위임 (notifyUser(푸시 동반) 아님)
            verify(notificationFacade, timeout(3000)).notifyUserInApp(
                    1L,
                    NotificationType.FOLLOW,
                    messageProvider.followReceived("유저2"),
                    2L
            );
        }
    }
}
