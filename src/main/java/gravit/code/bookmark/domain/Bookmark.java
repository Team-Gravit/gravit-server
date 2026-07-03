package gravit.code.bookmark.domain;

import gravit.code.global.consts.TimeZoneConst;
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
public class Bookmark {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "problem_id", nullable = false)
    private long problemId;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Builder(access = AccessLevel.PRIVATE)
    private Bookmark(long problemId, long userId) {
        this.problemId = problemId;
        this.userId = userId;
        this.createdAt = LocalDateTime.now(TimeZoneConst.KST);
    }

    public static Bookmark create(long problemId, long userId) {
        return Bookmark.builder()
                .problemId(problemId)
                .userId(userId)
                .build();
    }
}
