package gravit.code.notification.service;

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
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;

@TCSpringBootTest
@DisplayName("알림함 조회(NotificationQueryService)는")
class NotificationQueryServiceIntegrationTest {

    @Autowired
    private NotificationQueryService notificationQueryService;

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private UserFixture userFixture;

    @Nested
    @DisplayName("최신 30건 제한")
    class MaxSize {

        @Test
        void 알림이_30건을_초과하면_최신_30건만_반환한다() {
            // given - 동일 유저에게 35건 적재
            long userId = userFixture.일반_유저(1).getId();
            List<Notification> notifications = IntStream.range(0, 35)
                    .mapToObj(i -> Notification.create(userId, NotificationType.NOTICE, "알림" + i))
                    .toList();
            notificationRepository.saveAll(notifications);

            // when
            List<Notification> result = notificationQueryService.getNotifications(userId);

            // then
            assertThat(result).hasSize(30);
        }
    }

    @Nested
    @DisplayName("최근 30일 보관")
    class Retention {

        @Test
        @Transactional
        void 생성_30일_이전_알림은_제외하고_이내_알림만_반환한다() {
            // given - 고정 클럭 2025-08-05 기준 30일 컷오프는 2025-07-06
            long userId = userFixture.일반_유저(1).getId();
            // 30일 이전(제외 대상)
            notificationRepository.insertForAllActiveUsers(
                    NotificationType.NOTICE.name(), "오래된 알림", null, null, LocalDateTime.of(2025, 7, 1, 0, 0));
            // 30일 이내(노출 대상)
            notificationRepository.insertForAllActiveUsers(
                    NotificationType.NOTICE.name(), "최근 알림", null, null, LocalDateTime.of(2025, 8, 1, 0, 0));

            // when
            List<Notification> result = notificationQueryService.getNotifications(userId);

            // then
            assertThat(result)
                    .extracting(Notification::getMessage)
                    .containsExactly("최근 알림");
        }
    }
}
