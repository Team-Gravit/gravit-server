package gravit.code.admin.domain.staging;

import gravit.code.problem.domain.ProblemType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "problem_staging")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ProblemStaging {

    @Id
    private Long id;

    @Column(name = "lesson_id", nullable = false)
    private long lessonId;

    @Column(name = "content", columnDefinition = "text", nullable = false)
    private String content;

    @Column(name = "instruction", nullable = false)
    private String instruction;

    @Enumerated(EnumType.STRING)
    @Column(name = "problem_type", nullable = false)
    private ProblemType problemType;

    @Column(name = "label", nullable = false)
    private String label;

    @Builder(access = AccessLevel.PRIVATE)
    private ProblemStaging(
            Long id,
            long lessonId,
            String content,
            String instruction,
            ProblemType problemType,
            String label
    ) {
        this.id = id;
        this.lessonId = lessonId;
        this.content = content;
        this.instruction = instruction;
        this.problemType = problemType;
        this.label = label;
    }

    public static ProblemStaging create(
            Long id,
            long lessonId,
            String content,
            String instruction,
            ProblemType problemType,
            String label
    ) {
        return ProblemStaging.builder()
                .id(id)
                .lessonId(lessonId)
                .content(content)
                .instruction(instruction)
                .problemType(problemType)
                .label(label)
                .build();
    }

    public void updateContent(
            String instruction,
            String content
    ) {
        this.instruction = instruction;
        this.content = content;
    }
}
