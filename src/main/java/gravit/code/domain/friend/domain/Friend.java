package gravit.code.domain.friend.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "friends")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Friend {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "follower_id", columnDefinition = "bigint", nullable = false)
    private Long followerId;

    @Column(name = "followee_id", columnDefinition = "bigint", nullable = false)
    private Long followeeId;


    @Builder
    private Friend(Long followerId, Long followeeId) {
        this.followerId = followerId;
        this.followeeId = followeeId;
    }

    public static Friend create(Long followerId, Long followeeId) {
        return Friend.builder()
                .followerId(followerId)
                .followeeId(followeeId)
                .build();
    }
}
