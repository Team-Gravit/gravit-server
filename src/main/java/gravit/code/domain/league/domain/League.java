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
    private String tierName;

    @Column(name = "max_xp", columnDefinition = "integer", nullable = false)
    private Integer maxXp;

    @Column(name = "min_xp", columnDefinition = "integer", nullable = false)
    private Integer minXp;

    @Column(name = "league_img_url", columnDefinition = "varchar(150)", nullable = false)
    private String leagueImgUrl;

    @Builder
    private League(String tierName, Integer maxXp, Integer minXp, String leagueImgUrl) {
        this.tierName = tierName;
        this.maxXp = maxXp;
        this.minXp = minXp;
        this.leagueImgUrl = leagueImgUrl;
    }

    public static League create(String tierName, Integer maxXp, Integer minXp, String leagueImgUrl) {
        return League.builder()
                .tierName(tierName)
                .maxXp(maxXp)
                .minXp(minXp)
                .leagueImgUrl(leagueImgUrl)
                .build();
    }
}
