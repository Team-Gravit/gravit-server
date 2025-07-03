package gravit.code.problem.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class ProblemTest {

    @DisplayName("유효한 데이터로 주관식 문제를 생성할 수 있다")
    @Test
    void createSubjectiveProblemWithAvailableData(){
        // given
        ProblemType type = ProblemType.FILL_BLANK;
        String question = "문제 예시1";
        Long lessonId = 1L;
        String answer = "정답 예시1";

        // when
        SubjectiveProblem subjectiveProblem = SubjectiveProblem.create(
                type, question, lessonId, answer
        );

        // then
        assertThat(subjectiveProblem.getType()).isEqualTo(ProblemType.FILL_BLANK);
        assertThat(subjectiveProblem.getQuestion()).isEqualTo(question);
        assertThat(subjectiveProblem.getLessonId()).isEqualTo(lessonId);
        assertThat(subjectiveProblem.getAnswer()).isEqualTo(answer);
        assertThat(subjectiveProblem.getId()).isNull();
    }

    @DisplayName("유효한 데이터로 객관식 문제를 생성할 수 있다")
    @Test
    void createMultipleChoiceProblemWithAvailableData(){
        //given
        ProblemType type = ProblemType.FILL_BLANK;
        String question = "문제 예시1";
        Long lessonId = 1L;
        String answer = "정답 예시1";
        String options = "선지 예시1";

        MultipleChoiceProblem multipleChoiceProblem = MultipleChoiceProblem.create(
                type, question, lessonId, options, answer
        );

        assertThat(multipleChoiceProblem.getType()).isEqualTo(ProblemType.FILL_BLANK);
        assertThat(multipleChoiceProblem.getQuestion()).isEqualTo(question);
        assertThat(multipleChoiceProblem.getLessonId()).isEqualTo(lessonId);
        assertThat(multipleChoiceProblem.getOptions()).isEqualTo(options);
        assertThat(multipleChoiceProblem.getAnswer()).isEqualTo(answer);
        assertThat(multipleChoiceProblem.getId()).isNull();
    }
}