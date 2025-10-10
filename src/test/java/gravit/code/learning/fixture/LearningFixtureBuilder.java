package gravit.code.learning.fixture;

import gravit.code.learning.domain.Learning;
import org.springframework.boot.test.context.TestComponent;
import org.springframework.test.util.ReflectionTestUtils;

@TestComponent
public class LearningFixtureBuilder {

    private long recentChapterId;
    private boolean todaySolved;
    private int consecutiveDays;
    private int planetConquestRate;
    private long userId;
    private long version;

    public LearningFixtureBuilder builder(){
        return new LearningFixtureBuilder();
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

    public Learning build(){
        Learning learning = Learning.create(userId);

        ReflectionTestUtils.setField(learning, "recentChapterId", recentChapterId);
        ReflectionTestUtils.setField(learning, "todaySolved", todaySolved);
        ReflectionTestUtils.setField(learning, "consecutiveDays", consecutiveDays);
        ReflectionTestUtils.setField(learning, "planetConquestRate", planetConquestRate);
        ReflectionTestUtils.setField(learning, "version", version);

        return learning;
    }
}
