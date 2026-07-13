package gravit.code.global.event.retry;

import java.util.Map;

public interface RetryEventPublisher {
    void publish(String queueKey, Map<String, String> fields);
}
