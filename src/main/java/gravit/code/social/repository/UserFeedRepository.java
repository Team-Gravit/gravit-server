package gravit.code.social.repository;

import gravit.code.social.domain.UserFeed;
import gravit.code.social.dto.internal.SocialFeedProjection;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserFeedRepository extends JpaRepository<UserFeed, Long> {

    @Query("""
            SELECT new gravit.code.social.dto.internal.SocialFeedProjection(
                sf.id, sf.actorId, u.nickname, u.profileImgNumber, u.handle,
                sf.eventType, sf.eventValue, sf.createdAt
            )
            FROM UserFeed uf
            JOIN SocialFeed sf ON sf.id = uf.feedId
            JOIN User u ON u.id = sf.actorId
            WHERE uf.userId = :userId AND uf.hidden = false
            ORDER BY sf.createdAt DESC, sf.id DESC
            """)
    Slice<SocialFeedProjection> findVisibleFeedsByUserId(
            @Param("userId") long userId,
            Pageable pageable
    );

    Optional<UserFeed> findByUserIdAndFeedId(
            long userId,
            long feedId
    );
}
