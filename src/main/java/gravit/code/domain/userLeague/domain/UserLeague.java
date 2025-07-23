package gravit.code.domain.userLeague.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "user_league")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserLeague {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Column(name = "league_id", columnDefinition = "bigint", nullable = false)
    private Long leagueId;

    @Builder
    private UserLeague(Long userId, Long leagueId) {
        this.userId = userId;
        this.leagueId = leagueId;
    }

    public static UserLeague create(Long userId, Long leagueId) {
        return UserLeague.builder()
                .userId(userId)
                .leagueId(leagueId)
                .build();
    }
}
