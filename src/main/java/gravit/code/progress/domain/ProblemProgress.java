package gravit.code.progress.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Table(name = "problem_progress")
@Entity
@Getter
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ProblemProgress {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "is_correct", columnDefinition = "boolean", nullable = false)
    private boolean isCorrect;

    @Column(name = "incorrect_counts", columnDefinition = "bigint", nullable = false)
    private long incorrectCounts;

    @Column(name = "user_id",columnDefinition = "bigint", nullable = false)
    private long userId;

    @Column(name = "problem_id",columnDefinition = "bigint", nullable = false)
    private long problemId;

    @Column(name = "created_at",  nullable = false)
    @CreatedDate
    private LocalDateTime createdAt;

    @Builder
    private ProblemProgress(Boolean isCorrect, long incorrectCounts, long userId, long problemId) {
        this.isCorrect = isCorrect ;
        this.incorrectCounts = incorrectCounts;
        this.userId = userId;
        this.problemId = problemId;
    }

    public static ProblemProgress create(Boolean isCorrect, long incorrectCounts, long userId, long problemId) {
        return ProblemProgress.builder()
                .isCorrect(isCorrect)
                .incorrectCounts(incorrectCounts)
                .userId(userId)
                .problemId(problemId)
                .build();
    }
}
