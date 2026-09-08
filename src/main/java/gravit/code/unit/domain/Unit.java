package gravit.code.unit.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
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

    @Column(name = "note_path")
    private String notePath;

    @Builder(access = AccessLevel.PRIVATE)
    private Unit(
            String title,
            String description,
            long chapterId,
            String notePath
    ) {
        this.title = title;
        this.description = description;
        this.chapterId = chapterId;
        this.notePath = notePath;
    }

    public static Unit create(
            String title,
            String description,
            long chapterId
    ) {
        return create(title, description, chapterId, null);
    }

    public static Unit create(
            String title,
            String description,
            long chapterId,
            String notePath
    ) {
        return Unit.builder()
                .title(title)
                .description(description)
                .chapterId(chapterId)
                .notePath(notePath)
                .build();
    }

    public void update(
            String title,
            String description
    ) {
        this.title = title;
        this.description = description;
    }
}