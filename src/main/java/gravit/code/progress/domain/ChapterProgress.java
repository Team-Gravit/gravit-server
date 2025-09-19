package gravit.code.progress.domain;

import gravit.code.progress.dto.ChapterCompletedDto;
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
    private long totalUnits;

    @Column(name = "completed_units", columnDefinition = "bigint", nullable = false)
    private long completedUnits;

    @Column(name = "user_id", columnDefinition = "bigint", nullable = false)
    private long userId;

    @Column(name = "chapter_id", columnDefinition = "bigint", nullable = false)
    private long chapterId;

    @Builder
    private ChapterProgress(long totalUnits, long userId, long chapterId) {
        this.totalUnits = totalUnits;
        this.completedUnits = 0L;
        this.userId = userId;
        this.chapterId = chapterId;
    }

    public static ChapterProgress create(long totalUnits, long userId, long chapterId) {
        return ChapterProgress.builder()
                .totalUnits(totalUnits)
                .userId(userId)
                .chapterId(chapterId)
                .build();
    }

    public ChapterCompletedDto updateCompletedUnits(){
        long before = this.completedUnits;
        long after = this.completedUnits++;

        return new ChapterCompletedDto(
                before, after, this.totalUnits
        );
    }
}