package gravit.code.badge.domain;


import com.fasterxml.jackson.databind.JsonNode;
import gravit.code.badge.converter.JsonNodeConverter;
import gravit.code.global.doamin.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserBadge extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false)
    private Long userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="badge_id", nullable=false)
    private Badge badge;
}
