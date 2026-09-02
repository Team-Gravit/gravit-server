package gravit.code.interviewQuestion.repository;

import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.dto.internal.InterviewQuestionPoolItem;
import gravit.code.interviewQuestion.dto.internal.SelectedInterviewQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface InterviewQuestionRepository extends JpaRepository<InterviewQuestion, Long> {

    @Query("""
        select new gravit.code.interviewQuestion.dto.internal.InterviewQuestionPoolItem(
            q.id,
            q.categoryId,
            q.difficulty
        )
        from InterviewQuestion q
        where q.categoryId in :categoryIds
        """)
    List<InterviewQuestionPoolItem> findPoolByCategoryIds(@Param("categoryIds") List<Long> categoryIds);

    @Query("""
        select new gravit.code.interviewQuestion.dto.internal.SelectedInterviewQuestion(
            q.id,
            q.content
        )
        from InterviewQuestion q
        where q.id in :questionIds
        """)
    List<SelectedInterviewQuestion> findContentsByIds(@Param("questionIds") List<Long> questionIds);
}
