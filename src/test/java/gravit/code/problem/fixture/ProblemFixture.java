package gravit.code.problem.fixture;

import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import org.springframework.test.util.ReflectionTestUtils;

public class ProblemFixture {

    public static Problem 새_주관식_문제(
            String content,
            long lessonId
    ) {
        return Problem.create(ProblemType.SUBJECTIVE, "지시문", content, lessonId);
    }

    public static Problem 기본_객관식_문제(long lessonId) {
        Problem problem = Problem.create(
                ProblemType.OBJECTIVE,
                "다음 중 올바른 것을 고르시오.",
                "프로세스와 스레드의 차이점",
                lessonId
        );
        ReflectionTestUtils.setField(problem, "id", 1L);
        return problem;
    }

    public static Problem 기본_주관식_문제(long lessonId) {
        Problem problem = Problem.create(
                ProblemType.SUBJECTIVE,
                "빈칸을 채우시오.",
                "프로세스는 ___의 단위이다.",
                lessonId
        );
        ReflectionTestUtils.setField(problem, "id", 2L);
        return problem;
    }

    public static Problem 저장된_문제(
            long id,
            ProblemType type,
            long lessonId
    ) {
        Problem problem = Problem.create(type, "지시문" + id, "내용" + id, lessonId);
        ReflectionTestUtils.setField(problem, "id", id);
        return problem;
    }
}
