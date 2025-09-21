package gravit.code.learning.domain;

import gravit.code.learning.dto.StreakDto;
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
    private long recentChapterId;

    @Column(name = "today_solved", columnDefinition = "boolean", nullable = false)
    private boolean todaySolved;

    @Column(name = "consecutive_days", columnDefinition = "integer", nullable = false)
    private int consecutiveDays;

    @Column(name = "planet_conquest_rate", columnDefinition = "integer", nullable = false)
    private int planetConquestRate;

    @Column(name = "user_id", columnDefinition = "bigint",  nullable = false)
    private long userId;

    @Version
    @Column(columnDefinition = "bigint", nullable = false)
    private long version;

    @Builder
    private Learning(Long userId) {
        this.recentChapterId = 0L;
        this.todaySolved = false;
        this.consecutiveDays = 0;
        this.planetConquestRate = 0;
        this.userId = userId;
        this.version = 0L;
    }

    public static Learning create(long userId){
        return Learning.builder()
                .userId(userId)
                .build();
    }

    public StreakDto updateLearningStatus(long chapterId, Integer planetConquestRate){
        int before = this.consecutiveDays;

        if (this.todaySolved){
            this.recentChapterId = chapterId;

            int after = this.consecutiveDays;
            return new StreakDto(before, after);
        }else{
            this.recentChapterId = chapterId;
            this.todaySolved = true;
            this.consecutiveDays += 1;
            this.planetConquestRate =  planetConquestRate;

            int after = this.consecutiveDays;
            return new StreakDto(before, after);
        }
    }

    public void updateConsecutiveDays(){
        if(!this.todaySolved && consecutiveDays > 0){
            this.consecutiveDays = 0;
        }else{
            this.todaySolved = false;
        }
    }
}
