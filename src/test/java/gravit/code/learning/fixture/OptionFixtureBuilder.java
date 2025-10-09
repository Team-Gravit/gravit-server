package gravit.code.learning.fixture;

import gravit.code.learning.domain.Option;
import gravit.code.learning.domain.OptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;
import org.springframework.test.util.ReflectionTestUtils;

@TestComponent
@RequiredArgsConstructor
public class OptionFixtureBuilder {

    private final OptionRepository optionRepository;

    private String content;
    private String explanation;
    private boolean isAnswer;
    private long problemId;

    public OptionFixtureBuilder builder() {
        return new OptionFixtureBuilder(optionRepository);
    }

    public OptionFixtureBuilder content(String content) {
        this.content = content;
        return this;
    }

    public OptionFixtureBuilder explanation(String explanation) {
        this.explanation = explanation;
        return this;
    }

    public OptionFixtureBuilder isAnswer(boolean isAnswer) {
        this.isAnswer = isAnswer;
        return this;
    }

    public OptionFixtureBuilder problemId(long problemId) {
        this.problemId = problemId;
        return this;
    }

    public Option build() {
        Option option = new Option();

        ReflectionTestUtils.setField(option, "content", content);
        ReflectionTestUtils.setField(option, "explanation", explanation);
        ReflectionTestUtils.setField(option, "isAnswer", isAnswer);
        ReflectionTestUtils.setField(option, "problemId", problemId);

        return optionRepository.save(option);
    }
}