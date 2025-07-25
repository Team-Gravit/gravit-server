package gravit.code.domain.friend.infrastructure;

import gravit.code.domain.friend.domain.Friend;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface FriendJpaRepository extends JpaRepository<Friend, Long> {
    boolean existsByFollowerIdAndFolloweeId(Long followerId, Long followeeId);
    Optional<Friend> findByFolloweeIdAndFollowerId(Long followeeId, Long followerId);
}
