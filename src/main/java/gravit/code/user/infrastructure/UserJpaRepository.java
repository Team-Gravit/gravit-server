package gravit.code.user.infrastructure;

import gravit.code.user.domain.User;
import gravit.code.user.domain.UserLevel;
import gravit.code.user.dto.response.MyPageResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserJpaRepository extends JpaRepository<User, Long> {

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

    @Query("""
        SELECT u.level
        FROM User u
        WHERE u.id = :userId
    """)
    Optional<UserLevel> findUserLevelById(@Param("userId") long userId);

    @Query("""
        SELECT u.nickname
        FROM User u
        WHERE u.id = :userId
    """)
    Optional<String> findNicknameById(@Param("userId") long userId);
}
