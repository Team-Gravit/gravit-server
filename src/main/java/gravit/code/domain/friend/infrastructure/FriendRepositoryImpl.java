package gravit.code.domain.friend.infrastructure;


import gravit.code.domain.friend.domain.Friend;
import gravit.code.domain.friend.domain.FriendRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

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
}
