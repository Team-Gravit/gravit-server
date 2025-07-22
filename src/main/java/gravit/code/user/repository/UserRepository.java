package gravit.code.user.repository;

import gravit.code.user.domain.User;
import gravit.code.user.dto.response.UserMainPageInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    @Query("""
        SELECT new gravit.code.user.dto.response.UserMainPageInfo(u.nickname, u.level, u.xp)
        FROM User u
        WHERE u.id = :userId
    """)
    Optional<UserMainPageInfo> findUserMainPageInfoById(@Param("userId") Long userId);
}
