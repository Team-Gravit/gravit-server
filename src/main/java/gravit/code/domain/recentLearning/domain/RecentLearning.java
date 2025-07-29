package gravit.code.domain.recentLearning.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

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

    @Column(name = "total_lessons", columnDefinition = "bigint", nullable = false)
    private Long totalLessons;

    @Column(name = "completed_lessons", columnDefinition = "bigint", nullable = false)
    private Long completedLessons;

    @Column(name = "user_id", columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Builder
    private RecentLearning(Long userId){
        this.chapterId = 0L;
        this.chapterName = " ";
        this.totalLessons = 0L;
        this.completedLessons = 0L;
        this.userId = userId;
    }

    public static RecentLearning init(Long userId){
        return RecentLearning.builder()
                .userId(userId)
                .build();
    }

    public void update(Long chapterId, String chapterName, Long totalLessons, Long completedLessons) {
        this.chapterId = chapterId;
        this.chapterName = chapterName;
        this.totalLessons = totalLessons;
        this.completedLessons = completedLessons;
    }
}
