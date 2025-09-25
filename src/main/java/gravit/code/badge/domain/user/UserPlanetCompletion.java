package gravit.code.badge.domain.user;

import gravit.code.badge.domain.Planet;
import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserPlanetCompletion extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false)
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable=false)
    private Planet planet;

    @Builder
    private UserPlanetCompletion(
            Long userId,
            Planet planet
    ) {
        this.userId = userId;
        this.planet = planet;
    }

    public static UserPlanetCompletion of(
            long userId,
            Planet planet
    ) {
        return UserPlanetCompletion.builder().userId(userId).planet(planet).build();
    }
}
