package gravit.code.friend.domain;

import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;

import java.util.List;
import java.util.Optional;

public interface FriendRepository {
    void save(Friend friend);
    boolean existsByFollowerIdAndFolloweeId(Long followerId, Long followeeId);
    Optional<Friend> findByFolloweeIdAndFollowerId(Long followeeId, Long followerId);
    void delete(Friend friend);
    List<FollowerResponse> findByFollowersByFolloweeId(Long followeeId);
    List<FollowingResponse> findByFollowingsByFollowerId(Long followerId);
}
