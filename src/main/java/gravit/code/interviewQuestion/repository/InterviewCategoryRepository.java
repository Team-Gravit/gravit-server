package gravit.code.interviewQuestion.repository;

import gravit.code.interview.domain.InterviewMode;
import gravit.code.interviewQuestion.domain.InterviewCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface InterviewCategoryRepository extends JpaRepository<InterviewCategory, Long> {

    @Query("select c.id from InterviewCategory c where c.mode = :mode")
    List<Long> findIdsByMode(@Param("mode") InterviewMode mode);
}
