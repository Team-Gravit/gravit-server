package gravit.code.unit.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@Table(
        name = "unit",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_unit_chapter_display_order",
                columnNames = {"chapter_id", "display_order"}
        )
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Unit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", nullable = false)
    private String description;

    @Column(name = "chapter_id", nullable = false)
    private long chapterId;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    @Column(name = "note_path")
    private String notePath;

    @Builder(access = AccessLevel.PRIVATE)
    private Unit(
            String title,
            String description,
            long chapterId,
            int displayOrder,
            String notePath
    ) {
        this.title = title;
        this.description = description;
        this.chapterId = chapterId;
        this.displayOrder = displayOrder;
        this.notePath = notePath;
    }

    public static Unit create(
            String title,
            String description,
            long chapterId,
            int displayOrder
    ) {
        return create(title, description, chapterId, displayOrder, null);
    }

    public static Unit create(
            String title,
            String description,
            long chapterId,
            int displayOrder,
            String notePath
    ) {
        return Unit.builder()
                .title(title)
                .description(description)
                .chapterId(chapterId)
                .displayOrder(displayOrder)
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
