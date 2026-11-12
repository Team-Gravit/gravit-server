package gravit.code.wrongAnsweredNote.domain;

import gravit.code.global.consts.TimeZoneConst;
import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class WrongAnsweredNote extends BaseEntity {

    private static final int INITIAL_WRONG_COUNT = 1;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "problem_id", nullable = false)
    private long problemId;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Column(name = "wrong_count", nullable = false)
    private int wrongCount;

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;

    @Builder(access = AccessLevel.PRIVATE)
    private WrongAnsweredNote(
            long problemId,
            long userId
    ) {
        this.problemId = problemId;
        this.userId = userId;
        this.wrongCount = INITIAL_WRONG_COUNT;
    }

    public static WrongAnsweredNote create(
            long problemId,
            long userId
    ) {
        return WrongAnsweredNote.builder()
                .problemId(problemId)
                .userId(userId)
                .build();
    }

    public WrongAnsweredNote markWrong() {
        this.wrongCount++;
        this.resolvedAt = null;

        return this;
    }

    public void resolve() {
        if (isResolved())
            return;

        this.resolvedAt = LocalDateTime.now(TimeZoneConst.KST);
    }

    public boolean isResolved() {
        return resolvedAt != null;
    }
}
