package gravit.code.global.event.retry;

import java.util.Map;

public interface RetrySweepTarget {
    String queueKey();
    int maxAttempts();
    void reprocess(Map<String, String> fields);
}
