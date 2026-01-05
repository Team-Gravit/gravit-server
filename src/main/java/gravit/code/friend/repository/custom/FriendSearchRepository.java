package gravit.code.friend.repository.custom;

import gravit.code.friend.dto.SearchUser;
import gravit.code.global.dto.response.SliceResponse;

public interface FriendSearchRepository {
    SliceResponse<SearchUser> searchUsersByQueryText(
            long requesterId,
            String queryText,
            int page
    );
}
