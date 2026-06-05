package gravit.code.notification.listener;

import gravit.code.global.event.SeasonRolledOverEvent;
import gravit.code.notification.facade.NotificationFacade;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.transaction.TestTransaction;
import org.springframework.transaction.annotation.Transactional;

import static org.mockito.Mockito.after;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class NotificationEventListenerIntegrationTest {

    @Autowired
    private ApplicationEventPublisher publisher;

    @MockitoBean
    private NotificationFacade notificationFacade;

    @Nested
    @DisplayName("시즌 롤오버 이벤트를 처리할 때")
    class HandleSeasonRolledOver {

        @Test
        @Transactional
        @DisplayName("커밋 이후 새 시즌 시작 알림 발송을 위임한다")
        void 커밋_이후_새_시즌_알림_발송을_위임한다() {
            // when
            publisher.publishEvent(new SeasonRolledOverEvent("2025-S2"));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(notificationFacade, timeout(3000)).sendSeasonResetAlerts();
        }

        @Test
        @Transactional
        @DisplayName("트랜잭션이 롤백되면 알림을 발송하지 않는다")
        void 트랜잭션이_롤백되면_발송하지_않는다() {
            // when - flagForCommit 없이 종료 → 롤백
            publisher.publishEvent(new SeasonRolledOverEvent("2025-S2"));
            TestTransaction.end();

            // then - AFTER_COMMIT 리스너이므로 호출되지 않아야 한다
            verify(notificationFacade, after(500).never()).sendSeasonResetAlerts();
        }
    }
}
