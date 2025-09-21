package gravit.code.badge.domain.user;


import gravit.code.badge.domain.Badge;
import gravit.code.global.doamin.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "user_badge",
        uniqueConstraints = @UniqueConstraint(name="uk_user_badge", columnNames={"user_id","badge_id"}))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserBadge extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false)
    private Long userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="badge_id", nullable=false)
    private Badge badge;

    @Builder
    private UserBadge(Long userId, Badge badge) {
        this.userId = userId;
        this.badge = badge;
    }

    public static UserBadge of(long userId, Badge badge) {
        return UserBadge.builder().userId(userId).badge(badge).build();
    }
}
