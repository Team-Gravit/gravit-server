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

import java.time.LocalDateTime;
import java.time.ZoneId;

@Table(name = "user_feed")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserFeed extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Column(name = "feed_id", nullable = false)
    private long feedId;

    @Column(name = "is_hidden", nullable = false)
    private boolean hidden;

    @Column(name = "congratulated_at")
    private LocalDateTime congratulatedAt;

    @Builder(access = AccessLevel.PRIVATE)
    private UserFeed(
            long userId,
            long feedId
    ) {
        this.userId = userId;
        this.feedId = feedId;
        this.hidden = false;
    }

    public static UserFeed create(
            long userId,
            long feedId
    ) {
        return UserFeed.builder()
                .userId(userId)
                .feedId(feedId)
                .build();
    }

    public void hide() {
        this.hidden = true;
    }

    public void congratulate() {
        this.congratulatedAt = LocalDateTime.now(ZoneId.of("Asia/Seoul"));
        this.hidden = true;
    }
}
