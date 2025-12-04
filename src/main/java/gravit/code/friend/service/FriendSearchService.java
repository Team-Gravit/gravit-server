package gravit.code.friend.service;

import gravit.code.friend.dto.SearchUser;
import gravit.code.friend.infrastructure.FriendSearchRepository;
import gravit.code.global.dto.response.SliceResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class FriendSearchService {
    private final FriendSearchRepository friendSearchRepository;

    public SliceResponse<SearchUser> searchUsersForFollowing(
            Long requesterId,
            String queryText,
            int page
    ){
        int safePage = Math.max(0, page);
        return friendSearchRepository.searchUsersByQueryText(requesterId, queryText, safePage);
    }
}
