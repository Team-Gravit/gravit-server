package gravit.code.domain.userLeague.domain;

import org.springframework.data.repository.query.Param;

public interface UserLeagueRepository {

    String findUserLeagueNameByUserId(@Param("userId") Long userId);
}
