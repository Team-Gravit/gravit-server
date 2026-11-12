package gravit.code.social.domain;

import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "congratulation")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Congratulation extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Column(name = "actor_id", nullable = false)
    private long actorId;

    @Column(name = "feed_id", nullable = false)
    private long feedId;

    @Builder(access = AccessLevel.PRIVATE)
    private Congratulation(
            long userId,
            long actorId,
            long feedId
    ) {
        this.userId = userId;
        this.actorId = actorId;
        this.feedId = feedId;
    }

    public static Congratulation create(
            long userId,
            long actorId,
            long feedId
    ) {
        return Congratulation.builder()
                .userId(userId)
                .actorId(actorId)
                .feedId(feedId)
                .build();
    }
}
