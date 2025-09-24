package gravit.code.badge.domain;

import com.fasterxml.jackson.databind.JsonNode;
import gravit.code.badge.converter.JsonNodeConverter;
import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Badge extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private BadgeCategory category;

    @Column(nullable = false)
    private String code;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String description;

    @Column(nullable = false)
    private int iconId;

    @Column(nullable = false)
    private int displayOrder;

    @Enumerated(EnumType.STRING)
    @Column(nullable=false)
    private CriteriaType criteriaType;

    @Convert(converter = JsonNodeConverter.class)
    @Column(columnDefinition = "jsonb", nullable = false)
    private JsonNode criteriaParams;
}
