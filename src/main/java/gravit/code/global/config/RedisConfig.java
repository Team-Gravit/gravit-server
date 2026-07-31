package gravit.code.global.config;

import io.lettuce.core.ClientOptions;
import io.lettuce.core.SocketOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceClientConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.repository.configuration.EnableRedisRepositories;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import java.time.Duration;

@Configuration
@EnableRedisRepositories
public class RedisConfig {

    private static final Duration RANKING_COMMAND_TIMEOUT = Duration.ofMillis(100);

    private final String redisHost;
    private final int redisPort;

    public RedisConfig(
            @Value("${spring.data.redis.host}")String redisHost,
            @Value("${spring.data.redis.port}") int redisPort
    ) {
        this.redisHost = redisHost;
        this.redisPort = redisPort;
    }

    @Bean
    @Primary
    public RedisConnectionFactory redisConnectionFactory() {
        return new LettuceConnectionFactory(redisHost, redisPort);
    }

    @Bean
    @Primary
    public RedisTemplate<String, String> redisTemplate() {
        return stringRedisTemplate(redisConnectionFactory());
    }

    @Bean
    public RedisTemplate<String, String> rankingRedisTemplate() {
        return stringRedisTemplate(rankingRedisConnectionFactory());
    }

    @Bean
    public RedisConnectionFactory rankingRedisConnectionFactory() {
        LettuceClientConfiguration clientConfiguration = LettuceClientConfiguration.builder()
                .commandTimeout(RANKING_COMMAND_TIMEOUT)
                .clientOptions(ClientOptions.builder()
                        .socketOptions(SocketOptions.builder()
                                .connectTimeout(RANKING_COMMAND_TIMEOUT)
                                .build())
                        .build())
                .build();

        return new LettuceConnectionFactory(
                new RedisStandaloneConfiguration(redisHost, redisPort),
                clientConfiguration
        );
    }

    private RedisTemplate<String, String> stringRedisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, String> redisTemplate = new RedisTemplate<>();
        redisTemplate.setKeySerializer(new StringRedisSerializer());
        redisTemplate.setValueSerializer(new StringRedisSerializer());
        redisTemplate.setConnectionFactory(connectionFactory);

        return redisTemplate;
    }
}
