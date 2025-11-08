package gravit.code.learning.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Unit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "varchar(50)", nullable = false)
    private String name;

    @Column(name = "total_lessons", columnDefinition = "bigint", nullable = false)
    private long totalLessons;

    @Column(name = "chapter_id", columnDefinition = "bigint", nullable = false)
    private long chapterId;

    @Builder
    private Unit(
            String name,
            long totalLessons,
            long chapterId
    ) {
        this.name = name;
        this.totalLessons = totalLessons;
        this.chapterId = chapterId;
    }

    public static Unit create(
            String name,
            long totalLessons,
            long chapterId
    ) {
        return Unit.builder()
                .name(name)
                .totalLessons(totalLessons)
                .chapterId(chapterId)
                .build();
    }
}