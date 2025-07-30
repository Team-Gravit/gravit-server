package gravit.code.domain.recentLearning.domain;

import gravit.code.domain.chapterProgress.dto.response.ChapterInfo;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "recent_learning")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class RecentLearning {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "chapter_id", columnDefinition = "bigint", nullable = false)
    private Long chapterId;

    @Column(name = "chapter_name", columnDefinition = "varchar(100)", nullable = false)
    private String chapterName;

    @Column(name = "total_units", columnDefinition = "bigint", nullable = false)
    private Long totalUnits;

    @Column(name = "completed_units", columnDefinition = "bigint", nullable = false)
    private Long completedUnits;

    @Column(name = "user_id", columnDefinition = "bigint", nullable = false, unique = true)
    private Long userId;

    @Builder
    private RecentLearning(Long userId){
        this.chapterId = 0L;
        this.chapterName = " ";
        this.totalUnits = 0L;
        this.completedUnits = 0L;
        this.userId = userId;
    }

    public static RecentLearning init(Long userId){
        return RecentLearning.builder()
                .userId(userId)
                .build();
    }

    public void update(ChapterInfo chapterInfo) {
        this.chapterId = chapterInfo.chapterId();
        this.chapterName = chapterInfo.chapterName();
        this.totalUnits = chapterInfo.totalUnits();
        this.completedUnits = chapterInfo.completedUnits();
    }
}
