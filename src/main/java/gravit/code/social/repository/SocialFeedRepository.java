package gravit.code.social.repository;

import gravit.code.social.domain.SocialFeed;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SocialFeedRepository extends JpaRepository<SocialFeed, Long> {
}
