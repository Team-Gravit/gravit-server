package gravit.code.social.repository;

import gravit.code.social.domain.SocialFeed;
import gravit.code.social.dto.internal.SocialFeedProjection;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface SocialFeedRepository extends JpaRepository<SocialFeed, Long> {

    @Query("""
            SELECT new gravit.code.social.dto.internal.SocialFeedProjection(
                sf.id, sf.actorId, u.nickname, u.profileImgNumber, u.handle,
                sf.eventType, sf.eventValue, sf.createdAt
            )
            FROM SocialFeed sf
            JOIN User u ON u.id = sf.actorId
            WHERE sf.actorId IN :actorIds
            ORDER BY sf.createdAt DESC
            """)
    Slice<SocialFeedProjection> findFeedsByActorIds(
            @Param("actorIds") List<Long> actorIds,
            Pageable pageable
    );
}
