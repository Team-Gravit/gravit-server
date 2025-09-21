package gravit.code.season.service.port;

import java.util.Optional;

public interface SeasonClosedCache {
    Optional<Long> getLastClosedSeasonId();
    void setLastClosedSeasonId(long seasonId);
}
