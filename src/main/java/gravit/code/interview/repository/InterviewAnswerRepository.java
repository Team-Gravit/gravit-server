package gravit.code.interview.repository;

import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.dto.internal.InterviewSessionQuestionDto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface InterviewAnswerRepository extends JpaRepository<InterviewAnswer, Long> {

    List<InterviewAnswer> findAllBySessionIdOrderByDisplayOrderAsc(long sessionId);

    @Query("""
            SELECT new gravit.code.interview.dto.internal.InterviewSessionQuestionDto(a.displayOrder, q.content)
            FROM InterviewAnswer a JOIN InterviewQuestion q ON q.id = a.questionId
            WHERE a.sessionId = :sessionId
            ORDER BY a.displayOrder ASC
    """)
    List<InterviewSessionQuestionDto> findQuestionsBySessionId(@Param("sessionId") long sessionId);
}
