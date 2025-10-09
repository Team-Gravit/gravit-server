package gravit.code.learning.fixture;

import gravit.code.learning.domain.Problem;
import gravit.code.learning.domain.ProblemType;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class ProblemFixture {

    private final ProblemFixtureBuilder problemFixtureBuilder;

    private Problem 문제_정보(
            ProblemType problemType,
            String question,
            String content,
            String answer,
            long lessonId
    ) {
        return problemFixtureBuilder.builder()
                .problemType(problemType)
                .question(question)
                .content(content)
                .answer(answer)
                .lessonId(lessonId)
                .build();
    }

    public Problem 객관식_문제(long lessonId) {
        return 문제_정보(ProblemType.OBJECTIVE, "질문", "내용", "답", lessonId);
    }

    public Problem 주관식_문제(long lessonId) {
        return 문제_정보(ProblemType.SUBJECTIVE, "질문", "내용", "답", lessonId);
    }
}