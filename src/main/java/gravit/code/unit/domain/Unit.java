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

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String description;

    @Column(name = "chapter_id", nullable = false)
    private long chapterId;

    @Builder(access = AccessLevel.PRIVATE)
    private Unit(
            String title,
            String description,
            long chapterId
    ) {
        this.title = title;
        this.description = description;
        this.chapterId = chapterId;
    }

    public static Unit create(
            String title,
            String description,
            long chapterId
    ) {
        return Unit.builder()
                .title(title)
                .description(description)
                .chapterId(chapterId)
                .build();
    }
}