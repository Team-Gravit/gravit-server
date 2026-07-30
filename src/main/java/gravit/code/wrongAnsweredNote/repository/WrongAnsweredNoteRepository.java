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

    /**
     * 오답노트를 한 문장으로 일괄 저장한다.
     *
     * unnest가 문제 아이디 배열을 행으로 펼쳐 INSERT 대상을 만든다.
     * 배열을 파라미터 하나로 받으므로 문제 개수가 달라져도 SQL 원문이 바뀌지 않는다.
     * 컬렉션을 그대로 바인딩하면 (?, ?, ?)로 펼쳐져 개수마다 원문이 달라지고
     * pg_stat_statements 집계가 쪼개지므로, {@code {1,2,3}} 형태의 배열 리터럴 문자열로 넘긴다.
     *
     * 이미 있는 (user_id, problem_id)는 ix_wrong_answered_note_user_problem 유니크 인덱스에 걸려
     * DO UPDATE로 넘어가며, 결과는 {@link WrongAnsweredNote#markWrong()}과 같다(오답 횟수 증가, 극복 해제).
     * 조회와 저장이 한 문장이라 그 사이에 다른 트랜잭션이 끼어들 여지가 없다.
     *
     * 한 문장 안에 같은 (user_id, problem_id)가 두 번 들어오면 Postgres가 거부하므로
     * 호출자가 중복을 제거한 뒤 넘긴다.
     *
     * created_at / updated_at은 애플리케이션에서 KST로 계산해 넘긴다.
     * 네이티브 쿼리는 BaseEntity의 @PrePersist / @PreUpdate를 타지 않는다.
     */
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
        JOIN Unit u ON u.id = l.unitId
        LEFT JOIN Bookmark b on b.problemId = p.id AND b.userId = :userId
        WHERE wan.userId = :userId AND u.id = :unitId AND wan.resolvedAt IS NULL
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
        JOIN Unit u ON u.id = l.unitId
        WHERE u.id = :unitId AND wan.userId = :userId AND wan.resolvedAt IS NULL
    """)
    int countByUnitIdAndUserId(
            @Param("unitId")long unitId,
            @Param("userId")long userId
    );
}
