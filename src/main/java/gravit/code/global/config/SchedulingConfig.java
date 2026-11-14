package gravit.code.global.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;

@Configuration
@EnableScheduling
public class SchedulingConfig {

    @Bean(name = "taskScheduler")
    public ThreadPoolTaskScheduler taskScheduler() {
        return scheduler(1, "scheduling-");
    }

    @Bean(name = "retrySweepScheduler")
    public ThreadPoolTaskScheduler retrySweepScheduler() {
        return scheduler(4, "retry-sweep-");
    }

    private ThreadPoolTaskScheduler scheduler(
            int poolSize,
            String threadNamePrefix
    ) {
        ThreadPoolTaskScheduler scheduler = new ThreadPoolTaskScheduler();
        scheduler.setPoolSize(poolSize);
        scheduler.setThreadNamePrefix(threadNamePrefix);
        return scheduler;
    }
}
