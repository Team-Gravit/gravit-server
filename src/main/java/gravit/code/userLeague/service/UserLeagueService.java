package gravit.code.userLeague.service;

import gravit.code.userLeague.repository.UserLeagueRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserLeagueService {

    private final UserLeagueRepository userLeagueRepository;

    public String getUserLeagueName(Long userId){
        return userLeagueRepository.findUserLeagueNameByUserId(userId);
    }
}
