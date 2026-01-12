package gravit.code.problem.domain;

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

    @Column(nullable = false)
    private String instruction;

    @Column(columnDefinition = "text", nullable = false)
    private String content;

    @Column(name = "lesson_id", nullable = false)
    private long lessonId;

    @Builder(access = AccessLevel.PRIVATE)
    private Problem(
            ProblemType problemType,
            String instruction,
            String content,
            long lessonId
    ) {
        this.problemType = problemType;
        this.instruction = instruction;
        this.content = content;
        this.lessonId = lessonId;
    }

    public static Problem create(
            ProblemType problemType,
            String instruction,
            String content,
            long lessonId
    ) {
        return Problem.builder()
                .problemType(problemType)
                .instruction(instruction)
                .content(content)
                .lessonId(lessonId)
                .build();
    }

    public void updateProblem(ProblemUpdateRequest problemUpdateRequest){
        this.problemType = ProblemType.from(problemUpdateRequest.problemType());
        this.instruction = problemUpdateRequest.instruction();
        this.content = problemUpdateRequest.content();
    }

}