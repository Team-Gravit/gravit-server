package gravit.code.userProblemProgress.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "user_problem_progress")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserProblemProgress {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "is_correct", columnDefinition = "boolean", nullable = false)
    private boolean isCorrect;

    @Column(name = "incorrect_counts", columnDefinition = "integer", nullable = false)
    private int incorrectCounts;

    @Column(name = "user_id",columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Column(name = "problem_id",columnDefinition = "bigint", nullable = false)
    private Long problemId;

    @Builder
    private UserProblemProgress(Long userId, Long problemId) {
        this.isCorrect = false;
        this.incorrectCounts = 0;
        this.userId = userId;
        this.problemId = problemId;
    }

    public static UserProblemProgress create(Long userId, Long problemId) {
        return UserProblemProgress.builder()
                .userId(userId)
                .problemId(problemId)
                .build();
    }
}
