package gravit.code.support;

import java.time.Clock;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;

@TestConfiguration
public class FixedClockConfig {

    @Bean
    @Primary
    public Clock fixedClock() {
        return Clock.fixed(
                OffsetDateTime.parse("2025-08-05T12:00:00+09:00").toInstant(),
                ZoneId.of("Asia/Seoul")
        );
    }
}
