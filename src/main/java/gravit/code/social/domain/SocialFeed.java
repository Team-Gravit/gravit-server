package gravit.code.social.domain;

import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "social_feed")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class SocialFeed extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "actor_id", nullable = false)
    private long actorId;

    @Enumerated(EnumType.STRING)
    @Column(name = "event_type", nullable = false)
    private FeedEventType eventType;

    @Column(name = "event_value", nullable = false)
    private String eventValue;

    @Builder(access = AccessLevel.PRIVATE)
    private SocialFeed(
            long actorId,
            FeedEventType eventType,
            String eventValue
    ) {
        this.actorId = actorId;
        this.eventType = eventType;
        this.eventValue = eventValue;
    }

    public static SocialFeed create(
            long actorId,
            FeedEventType eventType,
            String eventValue
    ) {
        return SocialFeed.builder()
                .actorId(actorId)
                .eventType(eventType)
                .eventValue(eventValue)
                .build();
    }
}
