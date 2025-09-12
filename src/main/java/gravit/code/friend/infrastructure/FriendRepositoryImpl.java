package gravit.code.friend.infrastructure;


import gravit.code.friend.domain.Friend;
import gravit.code.friend.domain.FriendRepository;
import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import lombok.RequiredArgsConstructor;
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
    public boolean existsByFollowerIdAndFolloweeId(Long followerId, Long followeeId) {
        return jpaRepository.existsByFollowerIdAndFolloweeId(followerId, followeeId);
    }

    @Override
    public Optional<Friend> findByFolloweeIdAndFollowerId(Long followeeId, Long followerId) {
        return jpaRepository.findByFolloweeIdAndFollowerId(followeeId, followerId);
    }

    @Override
    public void delete(Friend friend) {
        jpaRepository.delete(friend);
    }

    @Override
    public List<FollowerResponse> findByFollowersByFolloweeId(Long followeeId) {
        return jpaRepository.findFollowersByFolloweeId(followeeId);
    }

    @Override
    public List<FollowingResponse> findByFollowingsByFollowerId(Long followerId) {
        return jpaRepository.findByFollowingsByFollowerId(followerId);
    }
}
