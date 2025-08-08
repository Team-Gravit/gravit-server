package gravit.code.domain.userLeague.domain;

import gravit.code.domain.user.domain.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Table(name = "user_league")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class UserLeague {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "league_id", columnDefinition = "bigint", nullable = false)
    private Long leagueId;

    @Column(name = "league_point", columnDefinition = "integer", nullable = false)
    private int lp;

    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Builder
    private UserLeague(User user, Long leagueId) {
        this.user = user;
        this.leagueId = leagueId;
        this.lp = 0;
    }

    public static UserLeague create(User user, Long leagueId) {
        return UserLeague.builder()
                .user(user)
                .leagueId(leagueId)
                .build();
    }
}
