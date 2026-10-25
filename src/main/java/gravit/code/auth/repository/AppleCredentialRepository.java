package gravit.code.auth.repository;

import gravit.code.auth.domain.AppleCredential;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface AppleCredentialRepository extends JpaRepository<AppleCredential, Long> {

    Optional<AppleCredential> findByUserId(long userId);

    @Modifying
    @Query("""
            DELETE FROM AppleCredential c
            WHERE c.userId = :userId
    """)
    void deleteByUserId(@Param("userId") long userId);
}
