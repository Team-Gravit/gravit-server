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

    @Column(columnDefinition = "varchar(50)", nullable = false, unique = true)
    private String name;

    @Column(columnDefinition = "text", nullable = false, unique = true)
    private String description;

    @Column(name = "total_units",columnDefinition = "bigint", nullable = false)
    private long totalUnits;

    @Builder
    private Chapter(
            String name,
            String description,
            long totalUnits
    ) {
        this.name = name;
        this.description = description;
        this.totalUnits = totalUnits;
    }

    public static Chapter create(
            String name,
            String description,
            long totalUnits
    ) {
        return Chapter.builder()
                .name(name)
                .description(description)
                .totalUnits(totalUnits)
                .build();
    }

}