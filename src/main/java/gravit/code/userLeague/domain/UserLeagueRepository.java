package gravit.code.userLeague.domain;

import gravit.code.league.domain.League;
import gravit.code.season.domain.Season;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserLeagueRepository {

    String findUserLeagueNameByUserId(@Param("userId") long userId);

    boolean existsByUserId(long userId);

    void save(UserLeague userLeague);

    Optional<UserLeague> findByUserId(long userId);

    int resetAllForNextSeason(
            Season currentSeason,
            Season nextSeason,
            League startLeague
    );
}
