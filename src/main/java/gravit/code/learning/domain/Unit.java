package gravit.code.learning.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class Unit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "varchar(50)", nullable = false)
    private String name;

    @Column(name = "total_lessons", columnDefinition = "bigint", nullable = false)
    private long totalLessons;

    @Column(name = "chapter_id", columnDefinition = "bigint", nullable = false)
    private long chapterId;
}