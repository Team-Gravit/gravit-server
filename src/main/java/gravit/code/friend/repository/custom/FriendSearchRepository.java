package gravit.code.friend.repository.custom;

import gravit.code.friend.dto.SearchUserDto;
import gravit.code.global.dto.response.SliceResponse;

public interface FriendSearchRepository {
    SliceResponse<SearchUserDto> searchUsersByQueryText(
            long requesterId,
            String queryText,
            int page
    );
}
