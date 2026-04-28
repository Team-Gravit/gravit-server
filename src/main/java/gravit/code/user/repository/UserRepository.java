package gravit.code.user.repository;

import gravit.code.admin.dto.response.UserDetailResponse;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserLevel;
import gravit.code.user.domain.UserStatus;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.user.repository.custom.UserDeletionRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

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

    @Query("""
        SELECT new gravit.code.admin.dto.response.UserDetailResponse(u.id, u.email, u.nickname, u.handle, u.role, u.status, u.createdAt)
        FROM User u
        WHERE(:search IS NULL OR u.email LIKE %:search% OR u.nickname LIKE %:search% OR u.handle LIKE %:search%)
            AND(:status IS NULL OR u.status = :status)
            AND(:role IS NULL OR u.role = :role)
    """)
    Page<UserDetailResponse> findByKeywordAndStatusAndRole(
            Pageable pageable,
            @Param("search") String search,
            @Param("status") UserStatus status,
            @Param("role") Role role
    );
}
