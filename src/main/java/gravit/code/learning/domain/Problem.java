package gravit.code.learning.domain;

import gravit.code.admin.dto.request.ProblemUpdateRequest;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Problem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "problem_type", nullable = false)
    private ProblemType problemType;

    @Column(columnDefinition = "text", nullable = false)
    private String question;

    @Column(columnDefinition = "text", nullable = false)
    private String content;

    @Column(columnDefinition = "text", nullable = false)
    private String answer;

    @Column(name = "lesson_id", columnDefinition = "bigint", nullable = false)
    private long lessonId;

    @Builder
    private Problem(
            ProblemType problemType,
            String question,
            String content,
            String answer,
            long lessonId
    ) {
        this.problemType = problemType;
        this.question = question;
        this.content = content;
        this.answer = answer;
        this.lessonId = lessonId;
    }

    public static Problem create(
            ProblemType problemType,
            String question,
            String content,
            String answer,
            long lessonId
    ) {
        return Problem.builder()
                .problemType(problemType)
                .question(question)
                .content(content)
                .answer(answer)
                .lessonId(lessonId)
                .build();
    }

    public void updateProblem(ProblemUpdateRequest problemUpdateRequest){
        this.problemType = ProblemType.from(problemUpdateRequest.problemType());
        this.question = problemUpdateRequest.question();
        this.content = problemUpdateRequest.content();
        this.answer = problemUpdateRequest.answer();
    }
}