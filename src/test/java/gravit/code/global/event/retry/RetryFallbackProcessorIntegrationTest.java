package gravit.code.global.event.retry;

import gravit.code.social.domain.FeedEventType;
import gravit.code.social.infrastructure.SocialFeedLevelUpRetryTarget;
import gravit.code.social.repository.SocialFeedRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.willThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class RetryFallbackProcessorIntegrationTest {

    private static final Map<String, String> LEVEL_UP_FIELDS = Map.of(
            SocialFeedLevelUpRetryTarget.FIELD_USER_ID, "1",
            SocialFeedLevelUpRetryTarget.FIELD_NEW_LEVEL, "5"
    );

    @Autowired
    private RetryFallbackProcessor retryFallbackProcessor;

    @Autowired
    private SocialFeedLevelUpRetryTarget levelUpRetryTarget;

    @Autowired
    private SocialFeedRepository socialFeedRepository;

    @Autowired
    private PlatformTransactionManager transactionManager;

    @MockitoBean
    private RetryEventPublisher retryEventPublisher;

    private void 큐_적재_실패() {
        willThrow(new RedisConnectionFailureException("재시도 큐 연결 실패"))
                .given(retryEventPublisher).publish(anyString(), anyMap());
    }

    private void 커밋_뒤에_실행(Runnable action) {
        new TransactionTemplate(transactionManager).executeWithoutResult(status ->
                TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                    @Override
                    public void afterCommit() {
                        action.run();
                    }
                }));
    }

    @Nested
    @DisplayName("재시도 큐 적재가 성공하면")
    class PublishSucceeded {

        @Test
        void 직접_처리하지_않는다() {
            // given
            RetrySweepTarget target = mock(RetrySweepTarget.class);
            given(target.queueKey()).willReturn("test-retry");

            // when
            retryFallbackProcessor.publishOrProcess(target, LEVEL_UP_FIELDS);

            // then
            verify(retryEventPublisher).publish("test-retry", LEVEL_UP_FIELDS);
            verify(target, never()).reprocess(anyMap());
        }
    }

    @Nested
    @DisplayName("재시도 큐 적재가 실패하면")
    class PublishFailed {

        @Test
        void 직접_처리한다() {
            // given
            큐_적재_실패();

            // when
            retryFallbackProcessor.publishOrProcess(levelUpRetryTarget, LEVEL_UP_FIELDS);

            // then
            assertThat(socialFeedRepository.findAll())
                    .anyMatch(f -> f.getEventType() == FeedEventType.LEVEL_UP && f.getEventValue().equals("5"));
        }

        @Test
        void 커밋_뒤에_호출돼도_직접_처리한_쓰기가_커밋된다() {
            // given
            큐_적재_실패();

            // when
            커밋_뒤에_실행(() -> retryFallbackProcessor.publishOrProcess(levelUpRetryTarget, LEVEL_UP_FIELDS));

            // then
            assertThat(socialFeedRepository.findAll())
                    .anyMatch(f -> f.getEventType() == FeedEventType.LEVEL_UP && f.getEventValue().equals("5"));
        }

        @Test
        void 직접_처리도_실패하면_예외를_던지지_않는다() {
            // given
            큐_적재_실패();
            RetrySweepTarget target = mock(RetrySweepTarget.class);
            given(target.queueKey()).willReturn("test-retry");
            willThrow(new IllegalStateException("직접 처리 실패")).given(target).reprocess(anyMap());

            // when & then
            assertThatCode(() -> retryFallbackProcessor.publishOrProcess(target, LEVEL_UP_FIELDS))
                    .doesNotThrowAnyException();
            verify(target).reprocess(LEVEL_UP_FIELDS);
        }
    }
}
