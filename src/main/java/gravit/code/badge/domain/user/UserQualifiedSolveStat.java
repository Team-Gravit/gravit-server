package gravit.code.badge.domain.user;

import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserQualifiedSolveStat extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private Long userId;

    @Column(nullable = false)
    private int qualifiedCount;

    @Builder
    private UserQualifiedSolveStat(Long userId) {
        this.userId = userId;
        this.qualifiedCount = 0;
    };

    public static UserQualifiedSolveStat of(Long userId) {
        return UserQualifiedSolveStat.builder()
                .userId(userId)
                .build();
    }

    public int applySolve(
            int accuracy,
            int seconds
    ){
        boolean qualified = (accuracy >= 85) && (seconds <= 120);
        if(qualified){
            this.qualifiedCount +=1;
        }

        return this.qualifiedCount;
    }

}
