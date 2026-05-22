package gravit.code.support;

import org.springframework.boot.test.util.TestPropertyValues;
import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.testcontainers.containers.GenericContainer;

public class RedisTestContainerConfig implements ApplicationContextInitializer<ConfigurableApplicationContext> {

    private static final int REDIS_PORT = 6379;
    private static final GenericContainer<?> CONTAINER =
            new GenericContainer<>("redis:7.0")
                    .withExposedPorts(REDIS_PORT);

    static {
        CONTAINER.start();
    }

    @Override
    public void initialize(ConfigurableApplicationContext applicationContext) {
        TestPropertyValues.of(
                "spring.data.redis.host=" + CONTAINER.getHost(),
                "spring.data.redis.port=" + CONTAINER.getMappedPort(REDIS_PORT)
        ).applyTo(applicationContext.getEnvironment());
    }
}
