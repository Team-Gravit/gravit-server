package gravit.code.problem.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "problem_submission")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ProblemSubmission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "is_correct", nullable = false)
    private boolean isCorrect;

    @Column(name = "problem_id", nullable = false)
    private long problemId;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Builder(access = AccessLevel.PRIVATE)
    private ProblemSubmission(
            boolean isCorrect,
            long problemId,
            long userId
    ) {
        this.isCorrect = isCorrect;
        this.problemId = problemId;
        this.userId = userId;
    }

    public static ProblemSubmission create(
            Boolean isCorrect,
            long problemId,
            long userId
    ) {
        return ProblemSubmission.builder()
                .isCorrect(isCorrect)
                .problemId(problemId)
                .userId(userId)
                .build();
    }

    public void updateIsCorrect(boolean isCorrect) {
        this.isCorrect = isCorrect;
    }
}
