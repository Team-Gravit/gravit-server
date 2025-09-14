package gravit.code.learning.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Learning {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "recent_chapter_id", columnDefinition = "bigint",  nullable = false)
    private Long recentChapterId;

    @Column(name = "today_solved", columnDefinition = "boolean", nullable = false)
    private Boolean todaySolved;

    @Column(name = "consecutive_days", columnDefinition = "integer", nullable = false)
    private Integer consecutiveDays;

    @Column(name = "planet_conquest_rate", columnDefinition = "double precision", nullable = false)
    private Double planetConquestRate;

    @Column(name = "user_id", columnDefinition = "bigint",  nullable = false)
    private Long userId;

    @Builder
    private Learning(Long userId) {
        this.recentChapterId = 0L;
        this.todaySolved = false;
        this.consecutiveDays = 0;
        this.planetConquestRate = 0.0;
        this.userId = userId;
    }

    public static Learning create(Long userId){
        return Learning.builder()
                .userId(userId)
                .build();
    }

    public void updateLearningStatus(Long chapterId, Double planetConquestRate){
        if (this.todaySolved){
            this.recentChapterId = chapterId;
        }else{
            this.todaySolved = true;
            this.consecutiveDays += 1;
            this.planetConquestRate =  planetConquestRate;
        }
    }

    public void resetConsecutiveDays(){
        this.consecutiveDays = 0;
    }
}
