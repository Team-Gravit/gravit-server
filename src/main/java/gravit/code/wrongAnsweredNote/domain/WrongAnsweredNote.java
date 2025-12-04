package gravit.code.wrongAnsweredNote.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class WrongAnsweredNote {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "problem_id", nullable = false)
    private long problemId;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Builder(access = AccessLevel.PRIVATE)
    private WrongAnsweredNote(
            long problemId,
            long userId
    ) {
        this.problemId = problemId;
        this.userId = userId;
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
}
