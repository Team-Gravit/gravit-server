package gravit.code.notification.repository;

import gravit.code.notification.domain.Notification;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    // 전체 활성 유저에게 동일 알림을 1쿼리로 적재 (공지 등 브로드캐스트용)
    @Modifying
    @Query(value = """
        INSERT INTO notification (user_id, type, message, sub_text, target_id, is_read, created_at, updated_at)
        SELECT u.id, :type, :message, :subText, :targetId, FALSE, :now, :now
        FROM users u
        WHERE u.deleted_at IS NULL
        """, nativeQuery = true)
    int insertForAllActiveUsers(
            @Param("type") String type,
            @Param("message") String message,
            @Param("subText") String subText,
            @Param("targetId") Long targetId,
            @Param("now") LocalDateTime now
    );

    // 알림함 노출 정책: 생성 후 30일 이내 알림만, 최신순으로 최대 30건(Pageable로 제한)
    @Query("SELECT n FROM Notification n WHERE n.userId = :userId AND n.createdAt >= :threshold ORDER BY n.createdAt DESC, n.id DESC")
    List<Notification> findRecent(
            @Param("userId") long userId,
            @Param("threshold") LocalDateTime threshold,
            Pageable pageable
    );
}
