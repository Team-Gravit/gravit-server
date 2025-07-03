package gravit.code.unit.domain;

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
    private Long totalLessons;

    @Column(name = "chapter_id", columnDefinition = "bigint", nullable = false)
    private Long chapterId;

    @Builder
    private Unit(String name, Long totalLessons, Long chapterId) {
        this.name = name;
        this.totalLessons = totalLessons;
        this.chapterId = chapterId;
    }

    public static Unit create(String name, Long totalLessons, Long chapterId) {
        return Unit.builder()
                .name(name)
                .totalLessons(totalLessons)
                .chapterId(chapterId)
                .build();
    }
}