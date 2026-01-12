package gravit.code.wrongAnsweredNote.repository;

import gravit.code.problem.dto.response.ProblemDetail;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface WrongAnsweredNoteRepository extends JpaRepository<WrongAnsweredNote, Long> {

    Optional<WrongAnsweredNote> findByProblemIdAndUserId(
            long problemId,
            long userId
    );

    @Query("""
        SELECT new gravit.code.problem.dto.response.ProblemDetail(
            p.id,
            p.problemType,
            p.instruction,
            p.content,
            CASE WHEN b.id IS NOT NULL THEN true ELSE false END
        )
        FROM WrongAnsweredNote wan
        JOIN Problem p ON p.id = wan.problemId
        JOIN Lesson l ON l.id = p.lessonId
        JOIN Unit u ON u.id = l.unitId
        LEFT JOIN Bookmark b on b.problemId = p.id AND b.userId = :userId
        WHERE wan.userId = :userId AND u.id = :unitId
    """)
    List<ProblemDetail> findWrongAnsweredProblemDetailByUnitIdAndUserId(
            @Param("unitId")long unitId,
            @Param("userId")long userId
    );

    void deleteByProblemIdAndUserId(
            long problemId,
            long userId
    );

    @Query("""
        SELECT COUNT(wan)
        FROM WrongAnsweredNote wan
        JOIN Problem p ON p.id = wan.problemId
        JOIN Lesson l ON l.id = p.lessonId
        JOIN Unit u ON u.id = l.unitId
        WHERE u.id = :unitId AND wan.userId = :userId
    """)
    int countByUnitIdAndUserId(
            @Param("unitId")long unitId,
            @Param("userId")long userId
    );
}
