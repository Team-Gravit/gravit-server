package gravit.code.domain.chapterProgress.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "chapter_progress")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ChapterProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "total_units", columnDefinition = "bigint", nullable = false)
    private Long totalUnits;

    @Column(name = "completed_units", columnDefinition = "bigint", nullable = false)
    private Long completedUnits;

    @Column(name = "user_id", columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Column(name = "chapter_id", columnDefinition = "bigint", nullable = false)
    private Long chapterId;

    @Builder
    private ChapterProgress(Long totalUnits, Long userId, Long chapterId) {
        this.totalUnits = totalUnits;
        this.completedUnits = 0L;
        this.userId = userId;
        this.chapterId = chapterId;
    }

    public static ChapterProgress create(Long totalUnits, Long userId, Long chapterId) {
        return ChapterProgress.builder()
                .totalUnits(totalUnits)
                .userId(userId)
                .chapterId(chapterId)
                .build();
    }

    public void updateCompletedUnits(){
        this.completedUnits++;
    }
}