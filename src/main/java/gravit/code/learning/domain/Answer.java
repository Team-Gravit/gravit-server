package gravit.code.learning.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Answer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String content;

    @Column(columnDefinition = "TEXT",  nullable = false)
    private String explanation;

    @Column(name = "problem_id")
    private long problemId;

    @Builder(access = AccessLevel.PRIVATE)
    private Answer(
            String content,
            String explanation,
            long problemId
    ) {
        this.content = content;
        this.explanation = explanation;
        this.problemId = problemId;
    }

    public static Answer create(
            String content,
            String explanation,
            long problemId
    ){
        return Answer.builder()
                .content(content)
                .explanation(explanation)
                .problemId(problemId)
                .build();
    }
}
