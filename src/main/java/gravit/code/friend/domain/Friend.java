package gravit.code.friend.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Friend {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "following_id", columnDefinition = "bigint", nullable = false)
    private Long followingId;

    @Column(name = "follower_id", columnDefinition = "bigint", nullable = false)
    private Long followerId;

    @Builder
    private Friend(Long followingId, Long followerId) {
        this.followingId = followingId;
        this.followerId = followerId;
    }

    public static Friend create(Long followingId, Long followerId) {
        return Friend.builder()
                .followingId(followingId)
                .followerId(followerId)
                .build();
    }
}
