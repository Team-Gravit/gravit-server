package gravit.code.interviewTechStack.repository;

import gravit.code.interviewTechStack.domain.InterviewJobRole;
import gravit.code.interviewTechStack.domain.InterviewTechStack;
import gravit.code.interviewTechStack.dto.response.InterviewTechStackResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface InterviewTechStackRepository extends JpaRepository<InterviewTechStack, Long> {

    @Query("""
        select new gravit.code.interviewTechStack.dto.response.InterviewTechStackResponse(
            t.id,
            t.code,
            t.displayName
        )
        from InterviewTechStack t
        where t.jobRole = :jobRole
        order by t.sortOrder asc
        """)
    List<InterviewTechStackResponse> findAllByJobRole(@Param("jobRole") InterviewJobRole jobRole);
}
