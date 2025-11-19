package gravit.code.learning.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Lesson {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(name = "unit_id", nullable = false)
    private long unitId;

    @Builder(access = AccessLevel.PRIVATE)
    private Lesson(
            String title,
            long unitId
    ) {
        this.title = title;
        this.unitId = unitId;
    }

    public static Lesson create(
            String title,
            long unitId
    ) {
        return Lesson.builder()
                .title(title)
                .unitId(unitId)
                .build();
    }
}
