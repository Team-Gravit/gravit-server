package gravit.code.admin.domain.staging;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "lesson_staging")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class LessonStaging {

    @Id
    private Long id;

    @Column(name = "unit_id", nullable = false)
    private long unitId;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "label", nullable = false)
    private String label;

    @Builder(access = AccessLevel.PRIVATE)
    private LessonStaging(
            Long id,
            long unitId,
            String title,
            String label
    ) {
        this.id = id;
        this.unitId = unitId;
        this.title = title;
        this.label = label;
    }

    public static LessonStaging create(
            Long id,
            long unitId,
            String title,
            String label
    ) {
        return LessonStaging.builder()
                .id(id)
                .unitId(unitId)
                .title(title)
                .label(label)
                .build();
    }

    public void updateTitle(String title) {
        this.title = title;
    }
}
