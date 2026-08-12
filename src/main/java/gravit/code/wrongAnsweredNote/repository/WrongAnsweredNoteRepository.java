package gravit.code.wrongAnsweredNote.repository;

import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface WrongAnsweredNoteRepository extends JpaRepository<WrongAnsweredNote, Long> {

    Optional<WrongAnsweredNote> findByProblemIdAndUserId(
            long problemId,
            long userId
    );

    @Modifying
    @Query(value = """
        INSERT INTO wrong_answered_note (user_id, problem_id, wrong_count, created_at, updated_at)
        SELECT :userId, p.problem_id, 1, :now, :now
        FROM unnest(CAST(:problemIds AS BIGINT[])) AS p(problem_id)
        ON CONFLICT (user_id, problem_id)
        DO UPDATE SET wrong_count = wrong_answered_note.wrong_count + 1,
                      resolved_at = NULL,
                      updated_at  = EXCLUDED.updated_at
    """, nativeQuery = true)
    void upsertAll(
            @Param("userId") long userId,
            @Param("problemIds") String problemIds,
            @Param("now") LocalDateTime now
    );

    @Query("""
        SELECT new gravit.code.problem.dto.response.ProblemDetailResponse(
            p.id,
            p.problemType,
            p.instruction,
            p.content,
            CASE WHEN b.id IS NOT NULL THEN true ELSE false END
        )
        FROM WrongAnsweredNote wan
        JOIN Problem p ON p.id = wan.problemId
        JOIN Lesson l ON l.id = p.lessonId
        LEFT JOIN Bookmark b on b.problemId = p.id AND b.userId = :userId
        WHERE wan.userId = :userId AND l.unitId = :unitId AND wan.resolvedAt IS NULL
    """)
    List<ProblemDetailResponse> findWrongAnsweredProblemDetailByUnitIdAndUserId(
            @Param("unitId")long unitId,
            @Param("userId")long userId
    );

    @Query("""
        SELECT COUNT(wan)
        FROM WrongAnsweredNote wan
        JOIN Problem p ON p.id = wan.problemId
        JOIN Lesson l ON l.id = p.lessonId
        WHERE l.unitId = :unitId AND wan.userId = :userId AND wan.resolvedAt IS NULL
    """)
    int countByUnitIdAndUserId(
            @Param("unitId")long unitId,
            @Param("userId")long userId
    );
}
