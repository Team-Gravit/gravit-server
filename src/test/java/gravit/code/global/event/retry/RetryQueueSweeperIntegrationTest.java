package gravit.code.global.event.retry;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.infrastructure.LeaguePointRetryTarget;
import gravit.code.userLeague.repository.LeaguePointGrantRepository;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.userLeague.service.UserLeaguePointService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.RedisSystemException;
import org.springframework.data.redis.core.ListOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;

import java.util.Map;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyDouble;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.spy;

@TCSpringBootTest
class RetryQueueSweeperIntegrationTest {

    private static final String QUEUE_KEY = LeaguePointRetryTarget.QUEUE_KEY;
    private static final String DEAD_LETTER_KEY = QUEUE_KEY + ":dead-letter";
    private static final String MALFORMED_PAYLOAD = "not-json";

    @Autowired
    private RetryQueueSweeper retryQueueSweeper;

    @Autowired
    private RetryEventPublisher retryEventPublisher;

    @Autowired
    private UserLeagueRepository userLeagueRepository;

    @Autowired
    private LeaguePointGrantRepository leaguePointGrantRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private LeagueFixture leagueFixture;

    @Autowired
    private SeasonFixture seasonFixture;

    @Autowired
    private UserLeagueFixture userLeagueFixture;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoSpyBean(name = "redisTemplate")
    private RedisTemplate<String, String> redisTemplate;

    @MockitoSpyBean
    private UserLeaguePointService pointService;

    private User user;

    @BeforeEach
    void setUp() {
        League 브론즈3 = leagueFixture.브론즈_3();
        Season season = seasonFixture.진행중인_시즌("S1");
        user = userFixture.일반_유저(1);
        userLeagueFixture.참여(user, season, 브론즈3, 0);
    }

    @Nested
    @DisplayName("재처리에 성공했을 때")
    class ReprocessSucceeded {

        @Test
        void 항목_제거에_실패해_두_번_스윕돼도_LP는_한_번만_오른다() {
            // given
            적재();
            ZSetOperations<String, String> zSetOps = spyZSetOps();
            doThrow(new RedisSystemException("제거 실패", null))
                    .doCallRealMethod()
                    .when(zSetOps).remove(eq(QUEUE_KEY), any());

            // when
            retryQueueSweeper.sweep();
            retryQueueSweeper.sweep();

            // then
            UserLeague updated = userLeagueRepository.findByUserId(user.getId()).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(updated.getLp()).isEqualTo(20);
                softly.assertThat(leaguePointGrantRepository.count()).isEqualTo(1);
                softly.assertThat(redisTemplate.opsForZSet().size(QUEUE_KEY)).isZero();
            });
        }
    }

    @Nested
    @DisplayName("재처리에 실패했을 때")
    class ReprocessFailed {

        @BeforeEach
        void setUp() {
            doThrow(new RuntimeException("DB 커넥션 실패"))
                    .when(pointService).addLeaguePointsForLesson(anyLong(), anyLong(), anyInt(), anyInt());
        }

        @Test
        void 재적재에_성공하면_원본을_지우고_다음_시도_항목만_남긴다() throws Exception {
            // given
            String original = 적재();

            // when
            retryQueueSweeper.sweep();

            // then
            Set<String> entries = redisTemplate.opsForZSet().range(QUEUE_KEY, 0, -1);
            assertThat(entries).hasSize(1).doesNotContain(original);

            Map<String, String> requeued = objectMapper.readValue(entries.iterator().next(), new TypeReference<>() {});
            assertSoftly(softly -> {
                softly.assertThat(requeued.get("__attempt")).isEqualTo("1");
                softly.assertThat(requeued.get(LeaguePointRetryTarget.FIELD_LESSON_ID)).isEqualTo("1");
            });
        }

        @Test
        void 재적재에_실패하면_원본_항목이_큐에_남는다() {
            // given
            String original = 적재();
            ZSetOperations<String, String> zSetOps = spyZSetOps();
            doThrow(new RedisSystemException("재적재 실패", null))
                    .when(zSetOps).add(eq(QUEUE_KEY), anyString(), anyDouble());

            // when
            retryQueueSweeper.sweep();

            // then
            assertThat(redisTemplate.opsForZSet().range(QUEUE_KEY, 0, -1)).containsExactly(original);
        }
    }

    @Nested
    @DisplayName("페이로드를 해석할 수 없을 때")
    class MalformedPayload {

        @BeforeEach
        void setUp() {
            redisTemplate.opsForZSet().add(QUEUE_KEY, MALFORMED_PAYLOAD, 0);
        }

        @Test
        void 데드레터_적재에_성공하면_큐에서_빠지고_데드레터에_원문이_남는다() {
            // when
            retryQueueSweeper.sweep();

            // then
            assertSoftly(softly -> {
                softly.assertThat(redisTemplate.opsForZSet().size(QUEUE_KEY)).isZero();
                softly.assertThat(redisTemplate.opsForList().range(DEAD_LETTER_KEY, 0, -1)).containsExactly(MALFORMED_PAYLOAD);
            });
        }

        @Test
        void 데드레터_적재에_실패하면_큐에_남는다() {
            // given
            ListOperations<String, String> listOps = spy(redisTemplate.opsForList());
            doThrow(new RedisSystemException("데드레터 적재 실패", null))
                    .when(listOps).leftPush(eq(DEAD_LETTER_KEY), anyString());
            doReturn(listOps).when(redisTemplate).opsForList();

            // when
            retryQueueSweeper.sweep();

            // then
            assertSoftly(softly -> {
                softly.assertThat(redisTemplate.opsForZSet().range(QUEUE_KEY, 0, -1)).containsExactly(MALFORMED_PAYLOAD);
                softly.assertThat(redisTemplate.opsForList().size(DEAD_LETTER_KEY)).isZero();
            });
        }
    }

    private String 적재() {
        retryEventPublisher.publish(QUEUE_KEY, Map.of(
                LeaguePointRetryTarget.FIELD_USER_ID, String.valueOf(user.getId()),
                LeaguePointRetryTarget.FIELD_LESSON_ID, "1",
                LeaguePointRetryTarget.FIELD_POINTS, "20",
                LeaguePointRetryTarget.FIELD_ACCURACY, "100"
        ));

        return redisTemplate.opsForZSet().range(QUEUE_KEY, 0, -1).iterator().next();
    }

    private ZSetOperations<String, String> spyZSetOps() {
        ZSetOperations<String, String> zSetOps = spy(redisTemplate.opsForZSet());
        doReturn(zSetOps).when(redisTemplate).opsForZSet();
        return zSetOps;
    }
}
