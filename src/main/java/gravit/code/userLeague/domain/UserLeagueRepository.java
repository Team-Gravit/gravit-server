package gravit.code.userLeague.domain;

import gravit.code.league.domain.League;
import gravit.code.season.domain.Season;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserLeagueRepository {

    String findUserLeagueNameByUserId(@Param("userId") Long userId);

    boolean existsByUserId(Long userId);

    void save(UserLeague userLeague);

    Optional<UserLeague> findByUserId(Long userId);

    int resetAllForNextSeason(Season currentSeason, Season nextSeason, League startLeague);
}
