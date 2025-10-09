package gravit.code.learning.fixture;

import gravit.code.learning.domain.Option;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class OptionFixture {

    private final OptionFixtureBuilder optionFixtureBuilder;

    private Option 선지_정보(
            String content,
            String explanation,
            boolean isAnswer,
            long problemId
    ) {
        return optionFixtureBuilder.builder()
                .content(content)
                .explanation(explanation)
                .isAnswer(isAnswer)
                .problemId(problemId)
                .build();
    }

    public Option 정답_선지(long problemId) {
        return 선지_정보("선지내용", "선지설명", true, problemId);
    }

    public Option 오답_선지(long problemId) {
        return 선지_정보("선지내용", "선지설명", false, problemId);
    }
}