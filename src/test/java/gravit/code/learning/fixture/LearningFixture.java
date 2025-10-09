package gravit.code.learning.fixture;

import gravit.code.learning.domain.Learning;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class LearningFixture {

    private final LearningFixtureBuilder learningFixtureBuilder;

    private Learning 학습_정보(
            long recentChapterId,
            boolean todaySolved,
            int consecutiveDays,
            int planetConquestRate,
            long userId,
            long version

    ){
        return learningFixtureBuilder.builder()
                .recentChapterId(recentChapterId)
                .todaySolved(todaySolved)
                .consecutiveDays(consecutiveDays)
                .planetConquestRate(planetConquestRate)
                .userId(userId)
                .version(version)
                .build();
    }

    public Learning 기본_학습_정보(long userId){
        return 학습_정보(1L, true, 10, 10, userId, 0L);
    }

    public Learning 당일_학습_완료(long userId){
        return 학습_정보(1L, true, 10, 10, userId, 0L);
    }

    public Learning 당일_학습_미완료(long userId){
        return 학습_정보(1L, false, 10, 10, userId, 0L);
    }
}
