package gravit.code.league.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class League {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "varchar(20)", nullable = false)
    private String name;

    @Column(name = "max_lp", columnDefinition = "integer", nullable = false)
    private int maxLp;

    @Column(name = "min_lp", columnDefinition = "integer", nullable = false)
    private int minLp;

    @Column(name = "sort_order", nullable = false, unique = true)
    private int sortOrder;

    @Builder
    private League(String name, int maxLp, int minLp, int sortOrder) {
        this.name = name;
        this.maxLp = maxLp;
        this.minLp = minLp;
        this.sortOrder = sortOrder;
    }

    public static League create(String name, int maxLp, int minLp, int sortOrder) {
        return League.builder()
                .name(name)
                .maxLp(maxLp)
                .minLp(minLp)
                .sortOrder(sortOrder)
                .build();
    }
}
