package gravit.code.chapter.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
public class Chapter {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", nullable = false)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "category", nullable = false)
    private ChapterCategory category;

    @Builder(access = AccessLevel.PRIVATE)
    private Chapter(
            String title,
            String description,
            ChapterCategory category
    ) {
        this.title = title;
        this.description = description;
        this.category = category;
    }

    public static Chapter create(
            String title,
            String description,
            ChapterCategory category
    ) {
        return Chapter.builder()
                .title(title)
                .description(description)
                .category(category)
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