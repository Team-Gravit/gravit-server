package gravit.code.season.service.port;

import java.time.Duration;

public interface SeasonPopupSeenStore {
    boolean markSeenIfFirst(
            long userId,
            long seasonId,
            Duration ttl
    );
}
