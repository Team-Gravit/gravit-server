package gravit.code.global.config;

import gravit.code.support.TCSpringBootTest;
import io.lettuce.core.ClientOptions;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.lettuce.LettuceClientConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;

import java.time.Duration;

import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class RedisConfigIntegrationTest {

    @Autowired
    @Qualifier("redisConnectionFactory")
    private RedisConnectionFactory redisConnectionFactory;

    @Autowired
    @Qualifier("rankingRedisConnectionFactory")
    private RedisConnectionFactory rankingRedisConnectionFactory;

    private LettuceClientConfiguration 클라이언트_설정(RedisConnectionFactory connectionFactory) {
        return ((LettuceConnectionFactory) connectionFactory).getClientConfiguration();
    }

    @Nested
    @DisplayName("기본 Redis 연결은")
    class DefaultConnection {

        @Test
        void 명령과_접속을_1초_안에_끝내고_끊긴_동안_명령을_거절한다() {
            // when
            LettuceClientConfiguration configuration = 클라이언트_설정(redisConnectionFactory);
            ClientOptions clientOptions = configuration.getClientOptions().orElseThrow();

            // then
            assertSoftly(softly -> {
                softly.assertThat(configuration.getCommandTimeout()).isEqualTo(Duration.ofSeconds(1));
                softly.assertThat(clientOptions.getSocketOptions().getConnectTimeout()).isEqualTo(Duration.ofSeconds(1));
                softly.assertThat(clientOptions.isAutoReconnect()).isTrue();
                softly.assertThat(clientOptions.getDisconnectedBehavior())
                        .isEqualTo(ClientOptions.DisconnectedBehavior.REJECT_COMMANDS);
            });
        }
    }

    @Nested
    @DisplayName("랭킹 Redis 연결은")
    class RankingConnection {

        @Test
        void 명령과_접속을_100ms_안에_끝내고_끊긴_동안_명령을_거절한다() {
            // when
            LettuceClientConfiguration configuration = 클라이언트_설정(rankingRedisConnectionFactory);
            ClientOptions clientOptions = configuration.getClientOptions().orElseThrow();

            // then
            assertSoftly(softly -> {
                softly.assertThat(configuration.getCommandTimeout()).isEqualTo(Duration.ofMillis(100));
                softly.assertThat(clientOptions.getSocketOptions().getConnectTimeout()).isEqualTo(Duration.ofMillis(100));
                softly.assertThat(clientOptions.isAutoReconnect()).isTrue();
                softly.assertThat(clientOptions.getDisconnectedBehavior())
                        .isEqualTo(ClientOptions.DisconnectedBehavior.REJECT_COMMANDS);
            });
        }
    }
}
