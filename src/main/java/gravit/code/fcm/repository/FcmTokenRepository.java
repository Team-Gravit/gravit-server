package gravit.code.fcm.repository;

import gravit.code.fcm.domain.FcmToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface FcmTokenRepository extends JpaRepository<FcmToken, Long> {
    Optional<FcmToken> findByDeviceId(String deviceId);

    boolean existsByUserIdAndDeviceId(
            long userId,
            String deviceId
    );

    @Query("""
            SELECT t
            FROM FcmToken t
            WHERE t.userId IN :userIds AND t.platform = 'ANDROID'
    """)
    List<FcmToken> findAndroidTokensByUserIdIn(@Param("userIds") List<Long> userIds);

    @Query("""
            SELECT t.token
            FROM FcmToken t
            WHERE t.platform = 'ANDROID'
    """)
    List<String> findAllAndroidTokens();
}
