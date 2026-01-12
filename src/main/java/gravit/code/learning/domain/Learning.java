package gravit.code.learning.domain;

import gravit.code.learning.dto.common.ConsecutiveSolvedDto;
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

    @Column(name = "recent_solved_chapter_id",  nullable = false)
    private long recentSolvedChapterId;

    @Column(name = "today_solved", nullable = false)
    private boolean todaySolved;

    @Column(name = "consecutive_solved_days", nullable = false)
    private int consecutiveSolvedDays;

    @Column(name = "planet_conquest_rate", nullable = false)
    private int planetConquestRate;

    @Column(name = "user_id", nullable = false, unique = true)
    private long userId;

    @Version
    @Column(nullable = false)
    private long version;

    @Builder(access = AccessLevel.PRIVATE)
    private Learning(Long userId) {
        this.recentSolvedChapterId = 0L;
        this.todaySolved = false;
        this.consecutiveSolvedDays = 0;
        this.planetConquestRate = 0;
        this.userId = userId;
        this.version = 0L;
    }

    public static Learning create(long userId){
        return Learning.builder()
                .userId(userId)
                .build();
    }

    public ConsecutiveSolvedDto updateLearningStatus(
            long chapterId,
            Integer planetConquestRate
    ){
        int before = this.consecutiveSolvedDays;

        if (this.todaySolved){
            this.recentSolvedChapterId = chapterId;
            this.planetConquestRate = planetConquestRate;

            int after = this.consecutiveSolvedDays;
            return new ConsecutiveSolvedDto(before, after);
        }else{
            this.recentSolvedChapterId = chapterId;
            this.todaySolved = true;
            this.consecutiveSolvedDays += 1;
            this.planetConquestRate =  planetConquestRate;

            int after = this.consecutiveSolvedDays;
            return new ConsecutiveSolvedDto(before, after);
        }
    }

    public void updateConsecutiveDays(){
        if(!this.todaySolved) {
            this.consecutiveSolvedDays = 0;
        }else{
            this.todaySolved = false;
        }
    }

}
