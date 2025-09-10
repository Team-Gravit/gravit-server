package gravit.code.domain.friend.service;

import gravit.code.domain.friend.dto.SearchUser;
import gravit.code.domain.friend.infrastructure.FriendSearchRepository;
import gravit.code.global.dto.SliceResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class FriendSearchService {
    private final FriendSearchRepository friendSearchRepository;

    public SliceResponse<SearchUser> searchUsersForFollowing(Long requesterId, String queryText, int page){
        int safePage = Math.max(0, page);
        return friendSearchRepository.searchUsersByQueryText(requesterId, queryText, safePage);
    }
}
