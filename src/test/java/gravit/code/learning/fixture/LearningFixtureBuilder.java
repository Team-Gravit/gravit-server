package gravit.code.learning.fixture;

import gravit.code.learning.domain.Learning;
import gravit.code.learning.domain.LearningRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class LearningFixtureBuilder {

    private final LearningRepository learningRepository;

    private long recentChapterId;
    private boolean todaySolved;
    private int consecutiveDays;
    private int planetConquestRate;
    private long userId;
    private long version;

    public LearningFixtureBuilder learning(){
        return new LearningFixtureBuilder(learningRepository);
    }

    public LearningFixtureBuilder recentChapterId(long recentChapterId){
        this.recentChapterId = recentChapterId;
        return this;
    }

    public LearningFixtureBuilder todaySolved(boolean todaySolved){
        this.todaySolved = todaySolved;
        return this;
    }

    public LearningFixtureBuilder consecutiveDays(int consecutiveDays){
        this.consecutiveDays = consecutiveDays;
        return this;
    }

    public LearningFixtureBuilder planetConquestRate(int planetConquestRate){
        this.planetConquestRate = planetConquestRate;
        return this;
    }

    public LearningFixtureBuilder userId(long userId){
        this.userId = userId;
        return this;
    }

    public LearningFixtureBuilder version(long version){
        this.version = version;
        return this;
    }

    public Learning create(){
        Learning learning = new Learning(recentChapterId, todaySolved, consecutiveDays, planetConquestRate, userId, version);
        return learningRepository.save(learning);
    }
}
