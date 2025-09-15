package gravit.code.user.infrastructure;

import gravit.code.mainPage.dto.response.MainPageResponse;
import gravit.code.user.domain.User;
import gravit.code.user.dto.response.MyPageResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserJpaRepository extends JpaRepository<User, Long> {

    Optional<User> findByProviderId(String providerId);

    boolean existsByNickname(String nickname);

    @Query("""
        SELECT new gravit.code.mainPage.dto.response.MainPageResponse(
            u.nickname,
            league.name,
            u.xp,
            u.level,
            m.missionType,
            l.planetConquestRate,
            l.consecutiveDays,
            CAST(CASE WHEN l.recentChapterId = 0 THEN 0 ELSE COALESCE(c.id, 0) END AS long),
            CASE WHEN l.recentChapterId = 0 THEN '-' ELSE COALESCE(c.name, '-') END,
            CASE WHEN l.recentChapterId = 0 THEN '-' ELSE COALESCE(c.description, '-') END,
            CAST(CASE WHEN l.recentChapterId = 0 THEN 0 ELSE COALESCE(c.totalUnits, 0) END AS long),
            CAST(CASE WHEN l.recentChapterId = 0 THEN 0 ELSE COALESCE(cp.completedUnits, 0) END AS long)
        )
        FROM User u
        LEFT JOIN Learning l ON l.userId = u.id
        LEFT JOIN Mission m ON m.userId = u.id
        LEFT JOIN UserLeague ul ON ul.user.id = u.id
        LEFT JOIN League league ON league.id = ul.league.id
        LEFT JOIN Chapter c ON c.id = l.recentChapterId AND l.recentChapterId != 0
        LEFT JOIN ChapterProgress cp ON cp.chapterId = c.id AND cp.userId = u.id
        WHERE u.id = :userId
    """)
    MainPageResponse findMainPageByUserId(@Param("userId") Long userId);

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
