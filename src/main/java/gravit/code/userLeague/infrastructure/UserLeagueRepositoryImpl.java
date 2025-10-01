package gravit.code.userLeague.infrastructure;

import gravit.code.league.domain.League;
import gravit.code.season.domain.Season;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.domain.UserLeagueRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class UserLeagueRepositoryImpl implements UserLeagueRepository {

    private final UserLeagueJpaRepository userLeagueJpaRepository;

    @Override
    public String findUserLeagueNameByUserId(long userId){
        return userLeagueJpaRepository.findUserLeagueNameByUserId(userId);
    }

    @Override
    public boolean existsByUserId(long userId) {
        return userLeagueJpaRepository.existsByUser_Id(userId);
    }

    @Override
    public void save(UserLeague userLeague) {
        userLeagueJpaRepository.save(userLeague);
    }

    @Override
    public Optional<UserLeague> findByUserId(long userId) {
        return userLeagueJpaRepository.findByUser_Id(userId);
    }

    @Override
    public int resetAllForNextSeason(
            Season currentSeason,
            Season nextSeason,
            League startLeague
    ) {
        return userLeagueJpaRepository.resetAllForNextSeason(currentSeason, nextSeason, startLeague);
    }
}
