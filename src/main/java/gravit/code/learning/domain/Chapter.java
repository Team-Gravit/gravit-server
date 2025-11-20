package gravit.code.learning.domain;

import jakarta.persistence.*;
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

    @Column(nullable = false, unique = true)
    private String title;

    @Column(nullable = false)
    private String description;

    @Builder(access = AccessLevel.PRIVATE)
    private Chapter(
            String title,
            String description
    ) {
        this.title = title;
        this.description = description;
    }

    public static Chapter create(
            String title,
            String description
    ) {
        return Chapter.builder()
                .title(title)
                .description(description)
                .build();
    }
}