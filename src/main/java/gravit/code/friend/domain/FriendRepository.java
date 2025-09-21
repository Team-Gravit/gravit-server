package gravit.code.friend.domain;

import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;

import java.util.List;
import java.util.Optional;

public interface FriendRepository {
    void save(Friend friend);
    boolean existsByFollowerIdAndFolloweeId(long followerId, long followeeId);
    Optional<Friend> findByFolloweeIdAndFollowerId(long followeeId, long followerId);
    void delete(Friend friend);
    List<FollowerResponse> findByFollowersByFolloweeId(long followeeId);
    List<FollowingResponse> findByFollowingsByFollowerId(long followerId);
}
