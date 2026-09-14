package gravit.code.admin.repository;

import gravit.code.admin.domain.AdminUser;
import gravit.code.user.domain.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface AdminUserRepository extends JpaRepository<User, Long> {

    @Query(value = """
            SELECT u.id AS userId, u.email AS email, u.nickname AS nickname, u.handle AS handle,
                   u.profile_img_number AS profileImgNumber, u.role AS role, u.status AS status,
                   u.level AS level, u.created_at AS createdAt
            FROM users u
            WHERE (:search IS NULL OR u.email ILIKE CONCAT('%', :search, '%')
                                  OR u.nickname ILIKE CONCAT('%', :search, '%')
                                  OR u.handle ILIKE CONCAT('%', :search, '%'))
              AND (:status IS NULL OR u.status = :status)
              AND (:role IS NULL OR u.role = :role)
            ORDER BY u.id DESC
    """, countQuery = """
            SELECT COUNT(*)
            FROM users u
            WHERE (:search IS NULL OR u.email ILIKE CONCAT('%', :search, '%')
                                  OR u.nickname ILIKE CONCAT('%', :search, '%')
                                  OR u.handle ILIKE CONCAT('%', :search, '%'))
              AND (:status IS NULL OR u.status = :status)
              AND (:role IS NULL OR u.role = :role)
    """, nativeQuery = true)
    Page<AdminUser> searchUsers(
            @Param("search") String search,
            @Param("status") String status,
            @Param("role") String role,
            Pageable pageable
    );

    @Query(value = """
            SELECT u.id AS userId, u.email AS email, u.nickname AS nickname, u.handle AS handle,
                   u.profile_img_number AS profileImgNumber, u.role AS role, u.status AS status,
                   u.level AS level, u.created_at AS createdAt
            FROM users u
            WHERE u.id = :userId
    """, nativeQuery = true)
    Optional<AdminUser> findRowById(@Param("userId") long userId);

    @Query(value = """
            SELECT COUNT(*)
            FROM users
            WHERE status <> 'DELETED'
    """, nativeQuery = true)
    long countActiveUsers();

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query(value = """
            UPDATE users
            SET role = :role
            WHERE id = :id
    """, nativeQuery = true)
    int updateRoleById(
            @Param("id") long id,
            @Param("role") String role
    );

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query(value = """
            UPDATE users
            SET status = :status,
                deleted_at = CASE WHEN :status = 'DELETED' THEN NOW() ELSE NULL END,
                handle = CASE WHEN :status = 'DELETED' THEN NULL ELSE handle END
            WHERE id = :id
    """, nativeQuery = true)
    int updateStatusById(
            @Param("id") long id,
            @Param("status") String status
    );

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query(value = """
            UPDATE users
            SET status = :status,
                deleted_at = NULL,
                handle = :handle
            WHERE id = :id
    """, nativeQuery = true)
    int restoreStatusById(
            @Param("id") long id,
            @Param("status") String status,
            @Param("handle") String handle
    );
}
