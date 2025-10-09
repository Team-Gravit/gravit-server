package gravit.code.learning.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
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
}