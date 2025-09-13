package gravit.code.user.infrastructure;

import gravit.code.user.domain.User;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.mainPage.dto.response.MainPageUserSummaryResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserJpaRepository extends JpaRepository<User, Long> {

    @Query("""
        SELECT new gravit.code.mainPage.dto.response.MainPageUserSummaryResponse(u.nickname, u.level.level, u.level.xp)
        FROM User u
        WHERE u.id = :userId
    """)
    Optional<MainPageUserSummaryResponse> findUserMainPageSummaryByUserId(@Param("userId") Long userId);

    Optional<User> findByProviderId(String providerId);

    boolean existsById(Long id);

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
    Optional<MyPageResponse> findMyPageByUserId(@Param("userId") Long userId);
}
