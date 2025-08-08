package gravit.code.domain.league.domain;

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
    private Integer maxLp;

    @Column(name = "min_lp", columnDefinition = "integer", nullable = false)
    private Integer minLp;

    @Column(name = "league_img_url", columnDefinition = "varchar(150)", nullable = false)
    private String leagueImgUrl;

    @Column(name = "sort_order", nullable = false, unique = true)
    private Integer sortOrder;

    @Builder
    private League(String name, Integer maxLp, Integer minLp, String leagueImgUrl, int sortOrder) {
        this.name = name;
        this.maxLp = maxLp;
        this.minLp = minLp;
        this.leagueImgUrl = leagueImgUrl;
        this.sortOrder = sortOrder;
    }

    public static League create(String name, Integer maxLp, Integer minLp, String leagueImgUrl, int sortOrder) {
        return League.builder()
                .name(name)
                .maxLp(maxLp)
                .minLp(minLp)
                .leagueImgUrl(leagueImgUrl)
                .sortOrder(sortOrder)
                .build();
    }
}
