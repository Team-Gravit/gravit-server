package gravit.code.learning.fixture;

import gravit.code.learning.domain.Learning;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class LearningFixture {

    private final LearningFixtureBuilder learningFixtureBuilder;

    public Learning 학습정보(
            long recentChapterId,
            boolean todaySolved,
            int consecutiveDays,
            int planetConquestRate,
            long userId,
            long version

    ){
        return learningFixtureBuilder.learning()
                .recentChapterId(recentChapterId)
                .todaySolved(todaySolved)
                .consecutiveDays(consecutiveDays)
                .planetConquestRate(planetConquestRate)
                .userId(userId)
                .version(version)
                .create();
    }

    public Learning 당일_학습_완료(
            long recentChapterId,
            int consecutiveDays,
            int planetConquestRate,
            long userId,
            long version
    ){
        return 학습정보(recentChapterId, true, consecutiveDays, planetConquestRate, userId, version)
    }

    public Learning 당일_학습_미완료(
            long recentChapterId,
            int consecutiveDays,
            int planetConquestRate,
            long userId,
            long version
    ){
        return 학습정보(recentChapterId, false, consecutiveDays, planetConquestRate, userId, version)
    }
}
