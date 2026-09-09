package gravit.code.interviewQuestion.repository;

import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.dto.internal.InterviewQuestionPoolDto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface InterviewQuestionRepository extends JpaRepository<InterviewQuestion, Long> {

    @Query("""
            SELECT new gravit.code.interviewQuestion.dto.internal.InterviewQuestionPoolDto(q.topic, q.id)
            FROM InterviewQuestion q
            WHERE q.topic IN :topics AND q.difficulty = :difficulty AND q.active = true
    """)
    List<InterviewQuestionPoolDto> findPoolByTopicsAndDifficulty(
            @Param("topics") Collection<InterviewTopic> topics,
            @Param("difficulty") InterviewDifficulty difficulty
    );
}
