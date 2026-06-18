package gravit.code.user.repository;

import gravit.code.user.domain.User;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.user.dto.response.UserSummaryResponse;
import gravit.code.user.repository.custom.UserDeletionRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;

public interface UserRepository extends JpaRepository<User, Long>, UserDeletionRepository {

    @Query(value = """
        SELECT * FROM users 
        WHERE provider_id = :providerId
        LIMIT 1
        """, nativeQuery = true
    )
    Optional<User> findByProviderId(@Param("providerId") String providerId);

    boolean existsById(long id);

    boolean existsByHandle(String handle);

    @Query("""
        SELECT new gravit.code.user.dto.response.MyPageResponse(u.nickname, u.profileImgNumber, u.handle,
        ( select count(f1)
          from Friend f1
          where f1.followeeId = :userId),
        ( select count(f2)
          from Friend f2
          where f2.followerId = :userId))
        from User u
        where u.id = :userId
    """)
    Optional<MyPageResponse> findMyPageByUserId(@Param("userId") long userId);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
        UPDATE User u
        SET u.lastAccessedAt = :now
        WHERE u.id = :userId
          AND (u.lastAccessedAt IS NULL OR u.lastAccessedAt < :startOfToday)
    """)
    int updateLastAccessedAt(
            @Param("userId") long userId,
            @Param("now") LocalDateTime now,
            @Param("startOfToday") LocalDateTime startOfToday
    );

    @Query("""
        SELECT u.id
        FROM User u
        WHERE u.lastAccessedAt >= :start AND u.lastAccessedAt < :end
    """)
    List<Long> findUserIdsLastAccessedBetween(
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end
    );

    // @SQLRestriction(deleted_at IS NULL)이 적용되어 탈퇴 유저는 결과에서 자동 제외된다
    @Query("""
        SELECT new gravit.code.user.dto.response.UserSummaryResponse(u.id, u.nickname, u.profileImgNumber)
        FROM User u
        WHERE u.id IN :ids
    """)
    List<UserSummaryResponse> findSummariesByIds(@Param("ids") Set<Long> ids);
}
