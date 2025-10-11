package gravit.code.learning.fixture;

import gravit.code.learning.domain.Problem;
import gravit.code.learning.domain.ProblemType;
import org.springframework.test.util.ReflectionTestUtils;

public class ProblemFixture {

    private static Problem 문제(
            ProblemType problemType,
            String question,
            String content,
            String answer,
            long lessonId
    ) {
        Problem problem = new Problem();

        ReflectionTestUtils.setField(problem, "problemType", problemType);
        ReflectionTestUtils.setField(problem, "question", question);
        ReflectionTestUtils.setField(problem, "content", content);
        ReflectionTestUtils.setField(problem, "answer", answer);
        ReflectionTestUtils.setField(problem, "lessonId", lessonId);

        return problem;
    }

    public static Problem 객관식_문제(long lessonId) {
        return 문제(ProblemType.OBJECTIVE, "질문", "내용", "-", lessonId);
    }

    public static Problem 주관식_문제(long lessonId) {
        return 문제(ProblemType.SUBJECTIVE, "질문", "내용", "답", lessonId);
    }

    public static Problem 저장된_객관식_문제(long problemId, long lessonId){
        Problem problem = 문제(ProblemType.OBJECTIVE, "질문", "내용", "-", lessonId);

        ReflectionTestUtils.setField(problem, "id", problemId);

        return problem;
    }

    public static Problem 저장된_주관식_문제(long problemId, long lessonId){
        Problem problem = 문제(ProblemType.SUBJECTIVE, "질문", "내용", "-", lessonId);

        ReflectionTestUtils.setField(problem, "id", problemId);

        return problem;
    }
}