package gravit.code.friend.infrastructure;

import gravit.code.friend.domain.Friend;
import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface FriendJpaRepository extends JpaRepository<Friend, Long> {
    boolean existsByFollowerIdAndFolloweeId(
            long followerId,
            long followeeId
    );

    Optional<Friend> findByFolloweeIdAndFollowerId(
            long followeeId,
            long followerId
    );

    @Query("""
        select new gravit.code.friend.dto.response.FollowerResponse(
            u.id,
            u.nickname,
            u.profileImgNumber,
            u.handle
        )
        from Friend f
        join User u on u.id = f.followerId
        where f.followeeId = :followeeId
""")
    Slice<FollowerResponse> findFollowersByFolloweeId(
            @Param("followeeId") long followeeId,
            Pageable pageable
    );

    @Query("""
        select new gravit.code.friend.dto.response.FollowingResponse(
            u.id,
            u.nickname,
            u.profileImgNumber,
            u.handle
        )
        from Friend f
        join User u on u.id = f.followeeId
        where f.followerId = :followerId
""")
    Slice<FollowingResponse> findFollowingsByFollowerId(
            @Param("followerId") long followerId,
            Pageable pageable
    );

    long countByFollowerId(long userId);

    long countByFolloweeId(long userId);
}
