package gravit.code.global.config;

import io.github.resilience4j.bulkhead.Bulkhead;
import io.github.resilience4j.bulkhead.BulkheadConfig;
import io.github.resilience4j.bulkhead.BulkheadRegistry;
import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig;
import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig.SlidingWindowType;
import io.github.resilience4j.circuitbreaker.CircuitBreakerRegistry;
import io.github.resilience4j.micrometer.tagged.TaggedBulkheadMetrics;
import io.github.resilience4j.micrometer.tagged.TaggedCircuitBreakerMetrics;
import io.micrometer.core.instrument.MeterRegistry;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.dao.QueryTimeoutException;
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.data.redis.RedisSystemException;

import java.time.Duration;

@Slf4j
@Configuration
public class ResilienceConfig {

    private static final String LEAGUE_RANKING_STORE_CIRCUIT_BREAKER = "league-ranking-store";
    private static final int CIRCUIT_BREAKER_SLIDING_WINDOW_SIZE = 20;
    private static final int CIRCUIT_BREAKER_MINIMUM_NUMBER_OF_CALLS = 10;
    private static final float CIRCUIT_BREAKER_FAILURE_RATE_THRESHOLD = 50;
    private static final Duration CIRCUIT_BREAKER_WAIT_DURATION_IN_OPEN_STATE = Duration.ofSeconds(10);
    private static final int CIRCUIT_BREAKER_PERMITTED_CALLS_IN_HALF_OPEN_STATE = 3;

    private static final String LEAGUE_RANK_DB_FALLBACK_BULKHEAD = "league-rank-db-fallback";
    private static final int BULKHEAD_MAX_CONCURRENT_CALLS = 4;
    private static final Duration BULKHEAD_MAX_WAIT_DURATION = Duration.ZERO;

    @Bean
    public CircuitBreaker leagueRankingStoreCircuitBreaker(MeterRegistry meterRegistry) {
        CircuitBreakerConfig config = CircuitBreakerConfig.custom()
                .slidingWindowType(SlidingWindowType.COUNT_BASED)
                .slidingWindowSize(CIRCUIT_BREAKER_SLIDING_WINDOW_SIZE)
                .minimumNumberOfCalls(CIRCUIT_BREAKER_MINIMUM_NUMBER_OF_CALLS)
                .failureRateThreshold(CIRCUIT_BREAKER_FAILURE_RATE_THRESHOLD)
                .waitDurationInOpenState(CIRCUIT_BREAKER_WAIT_DURATION_IN_OPEN_STATE)
                .permittedNumberOfCallsInHalfOpenState(CIRCUIT_BREAKER_PERMITTED_CALLS_IN_HALF_OPEN_STATE)
                .recordExceptions(
                        RedisConnectionFailureException.class,
                        RedisSystemException.class,
                        QueryTimeoutException.class
                )
                .build();

        CircuitBreakerRegistry registry = CircuitBreakerRegistry.of(config);
        TaggedCircuitBreakerMetrics.ofCircuitBreakerRegistry(registry).bindTo(meterRegistry);

        CircuitBreaker circuitBreaker = registry.circuitBreaker(LEAGUE_RANKING_STORE_CIRCUIT_BREAKER);
        circuitBreaker.getEventPublisher()
                .onStateTransition(event -> log.warn("랭킹 저장소 서킷 브레이커 상태 전이: name={}, transition={}",
                        event.getCircuitBreakerName(), event.getStateTransition()));

        return circuitBreaker;
    }

    @Bean
    public Bulkhead leagueRankDatabaseBulkhead(MeterRegistry meterRegistry) {
        BulkheadConfig config = BulkheadConfig.custom()
                .maxConcurrentCalls(BULKHEAD_MAX_CONCURRENT_CALLS)
                .maxWaitDuration(BULKHEAD_MAX_WAIT_DURATION)
                .build();

        BulkheadRegistry registry = BulkheadRegistry.of(config);
        TaggedBulkheadMetrics.ofBulkheadRegistry(registry).bindTo(meterRegistry);

        return registry.bulkhead(LEAGUE_RANK_DB_FALLBACK_BULKHEAD);
    }
}
