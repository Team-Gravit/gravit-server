package gravit.code.friend.repository;

import gravit.code.friend.domain.Friend;
import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import gravit.code.friend.repository.custom.FriendSearchRepository;
import java.util.Optional;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface FriendRepository extends JpaRepository<Friend, Long>, FriendSearchRepository {
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

    @Query("""
            select count(f)
            from Friend f
            where f.followerId = :userId
            and exists(
                select 1 from User u
                where u.id = f.followeeId
            )
            """)
    long countByFollowerId(long userId);

    @Query("""
            select count(f)
            from Friend f
            where f.followeeId = :userId
            and exists(
                select 1 from User u
                where u.id = f.followerId
            )
            """)
    long countByFolloweeId(long userId);
}
