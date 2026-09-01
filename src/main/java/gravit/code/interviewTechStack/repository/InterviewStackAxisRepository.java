package gravit.code.interviewTechStack.repository;

import gravit.code.interviewTechStack.domain.InterviewStackAxis;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface InterviewStackAxisRepository extends JpaRepository<InterviewStackAxis, Long> {

    @Query("select sa.categoryId from InterviewStackAxis sa where sa.techStackId = :techStackId")
    List<Long> findCategoryIdsByTechStackId(@Param("techStackId") long techStackId);
}
