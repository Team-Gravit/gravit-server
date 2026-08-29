package gravit.code.interviewQuestion.domain;

import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "interview_question")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewQuestion extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "category_id", nullable = false)
    private long categoryId;

    @Column(name = "unit_id", nullable = false)
    private long unitId;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty", nullable = false)
    private InterviewDifficulty difficulty;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewQuestion(
            long categoryId,
            long unitId,
            String content,
            InterviewDifficulty difficulty
    ) {
        this.categoryId = categoryId;
        this.unitId = unitId;
        this.content = content;
        this.difficulty = difficulty;
    }

    public static InterviewQuestion create(
            long categoryId,
            long unitId,
            String content,
            InterviewDifficulty difficulty
    ) {
        return InterviewQuestion.builder()
                .categoryId(categoryId)
                .unitId(unitId)
                .content(content)
                .difficulty(difficulty)
                .build();
    }
}
