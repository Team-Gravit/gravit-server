package gravit.code.learning.fixture;

import gravit.code.learning.domain.Problem;
import gravit.code.learning.domain.ProblemRepository;
import gravit.code.learning.domain.ProblemType;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;
import org.springframework.test.util.ReflectionTestUtils;

@TestComponent
@RequiredArgsConstructor
public class ProblemFixtureBuilder {

    private final ProblemRepository problemRepository;

    private ProblemType problemType;
    private String question;
    private String content;
    private String answer;
    private long lessonId;

    public ProblemFixtureBuilder builder() {
        return new ProblemFixtureBuilder(problemRepository);
    }

    public ProblemFixtureBuilder problemType(ProblemType problemType) {
        this.problemType = problemType;
        return this;
    }

    public ProblemFixtureBuilder question(String question) {
        this.question = question;
        return this;
    }

    public ProblemFixtureBuilder content(String content) {
        this.content = content;
        return this;
    }

    public ProblemFixtureBuilder answer(String answer) {
        this.answer = answer;
        return this;
    }

    public ProblemFixtureBuilder lessonId(long lessonId) {
        this.lessonId = lessonId;
        return this;
    }

    public Problem build() {
        Problem problem = new Problem();

        ReflectionTestUtils.setField(problem, "problemType", problemType);
        ReflectionTestUtils.setField(problem, "question", question);
        ReflectionTestUtils.setField(problem, "content", content);
        ReflectionTestUtils.setField(problem, "answer", answer);
        ReflectionTestUtils.setField(problem, "lessonId", lessonId);

        return problemRepository.save(problem);
    }
}