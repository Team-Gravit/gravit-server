package gravit.code.friend.infrastructure;


import gravit.code.friend.domain.Friend;
import gravit.code.friend.domain.FriendRepository;
import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class FriendRepositoryImpl implements FriendRepository {

    private final FriendJpaRepository jpaRepository;

    @Override
    public void save(Friend friend) {
        jpaRepository.save(friend);
    }

    @Override
    public boolean existsByFollowerIdAndFolloweeId(
            long followerId,
            long followeeId
    ) {
        return jpaRepository.existsByFollowerIdAndFolloweeId(followerId, followeeId);
    }

    @Override
    public Optional<Friend> findByFolloweeIdAndFollowerId(long followeeId, long followerId) {
        return jpaRepository.findByFolloweeIdAndFollowerId(followeeId, followerId);
    }

    @Override
    public void delete(Friend friend) {
        jpaRepository.delete(friend);
    }

    @Override
    public Slice<FollowerResponse> findFollowersByFolloweeId(
            long followeeId,
            Pageable pageable
    ) {
        return jpaRepository.findFollowersByFolloweeId(followeeId, pageable);
    }

    @Override
    public Slice<FollowingResponse> findFollowingsByFollowerId(
            long followerId,
            Pageable pageable
    ) {
        return jpaRepository.findFollowingsByFollowerId(followerId, pageable);
    }
}
