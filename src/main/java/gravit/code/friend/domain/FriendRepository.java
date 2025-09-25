package gravit.code.friend.domain;

import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;

import java.util.Optional;

public interface FriendRepository {
    void save(Friend friend);

    boolean existsByFollowerIdAndFolloweeId(
            long followerId,
            long followeeId
    );

    Optional<Friend> findByFolloweeIdAndFollowerId(
            long followeeId,
            long followerId
    );

    void delete(Friend friend);

    Slice<FollowerResponse> findFollowersByFolloweeId(
            long followeeId,
            Pageable pageable
    );

    Slice<FollowingResponse> findFollowingsByFollowerId(
            long followerId,
            Pageable pageable
    );
}
