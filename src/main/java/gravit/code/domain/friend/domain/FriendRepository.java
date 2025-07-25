package gravit.code.domain.friend.domain;

import java.util.Optional;

public interface FriendRepository {
    void save(Friend friend);
    boolean existsByFollowerIdAndFolloweeId(Long followerId, Long followeeId);
    Optional<Friend> findByFolloweeIdAndFollowerId(Long followeeId, Long followerId);
    void delete(Friend friend);
}
