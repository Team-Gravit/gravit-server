package gravit.code.friend.domain;

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

@Table(name = "friends")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Friend extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "follower_id", columnDefinition = "bigint", nullable = false)
    private Long followerId;

    @Column(name = "followee_id", columnDefinition = "bigint", nullable = false)
    private Long followeeId;


    @Builder
    private Friend(
            long followerId,
            long followeeId
    ) {
        this.followerId = followerId;
        this.followeeId = followeeId;
    }

    public static Friend create(
            long followerId,
            long followeeId
    ) {
        return Friend.builder()
                .followerId(followerId)
                .followeeId(followeeId)
                .build();
    }
}
