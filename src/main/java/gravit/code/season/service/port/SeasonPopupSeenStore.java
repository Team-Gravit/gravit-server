package gravit.code.season.service.port;

import java.time.Duration;

public interface SeasonPopupSeenStore {
    // true 면 이번에 최초 팝업 노출, false 면 이미 본 적 있음
    boolean markSeenIfFirst(long userId, long seasonId, Duration ttl);
}
