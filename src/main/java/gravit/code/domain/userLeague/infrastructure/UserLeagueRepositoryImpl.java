package gravit.code.domain.userLeague.infrastructure;

import gravit.code.domain.league.domain.League;
import gravit.code.domain.season.domain.Season;
import gravit.code.domain.userLeague.domain.UserLeague;
import gravit.code.domain.userLeague.domain.UserLeagueRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class UserLeagueRepositoryImpl implements UserLeagueRepository {

    private final UserLeagueJpaRepository userLeagueJpaRepository;

    @Override
    public String findUserLeagueNameByUserId(Long userId){
        return userLeagueJpaRepository.findUserLeagueNameByUserId(userId);
    }

    @Override
    public boolean existsByUserId(Long userId) {
        return userLeagueJpaRepository.existsByUserId(userId);
    }

    @Override
    public void save(UserLeague userLeague) {
        userLeagueJpaRepository.save(userLeague);
    }

    @Override
    public Optional<UserLeague> findByUserId(Long userId) {
        return userLeagueJpaRepository.findById(userId);
    }

    @Override
    public int resetAllForNextSeason(Season currentSeason, Season nextSeason, League startLeague) {
        return userLeagueJpaRepository.resetAllForNextSeason(currentSeason, nextSeason, startLeague);
    }
}
