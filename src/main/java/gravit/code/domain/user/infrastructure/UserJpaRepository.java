package gravit.code.domain.user.infrastructure;

import gravit.code.domain.user.domain.User;
import gravit.code.domain.user.dto.response.UserMainPageInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserJpaRepository extends JpaRepository<User, Long> {

    @Query("""
        SELECT new gravit.code.domain.user.dto.response.UserMainPageInfo(u.nickname, u.level, u.xp)
        FROM User u
        WHERE u.id = :userId
    """)
    Optional<UserMainPageInfo> findUserMainPageInfoByUserId(@Param("userId") Long userId);

    Optional<User> findByProviderId(String providerId);

    boolean existsByNickname(String nickname);
}
