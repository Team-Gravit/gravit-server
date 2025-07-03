package gravit.code.userChapterProgress.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "user_chapter_progress")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserChapterProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "completed_units", columnDefinition = "bigint", nullable = false)
    private Long completedUnits;

    @Column(name = "user_id",columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Column(name = "chapter_id",columnDefinition = "bigint", nullable = false)
    private Long chapterId;

    @Builder
    private UserChapterProgress(Long userId, Long chapterId) {
        this.completedUnits = 0L;
        this.userId = userId;
        this.chapterId = chapterId;
    }

    public static UserChapterProgress create(Long userId, Long chapterId) {
        return UserChapterProgress.builder()
                .userId(userId)
                .chapterId(chapterId)
                .build();
    }
}