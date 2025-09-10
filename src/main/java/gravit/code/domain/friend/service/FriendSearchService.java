package gravit.code.domain.friend.service;

import gravit.code.domain.friend.dto.response.PageSearchUserResponse;
import gravit.code.domain.friend.infrastructure.FriendSearchRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class FriendSearchService {
    private final FriendSearchRepository friendSearchRepository;

    public PageSearchUserResponse searchUsersForFollowing(Long requesterId, String queryText, int page){
        int safePage = Math.max(0, page);
        return friendSearchRepository.searchUsersByQueryText(requesterId, queryText, safePage);
    }
}
