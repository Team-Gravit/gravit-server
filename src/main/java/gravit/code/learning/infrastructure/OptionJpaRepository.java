package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Option;
import gravit.code.learning.dto.response.OptionResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OptionJpaRepository extends JpaRepository<Option, Long> {

    @Query("""
        SELECT new gravit.code.learning.dto.response.OptionResponse(o.content, o.explanation, o.isAnswer, o.problemId)
        FROM Option o
        WHERE o.problemId IN (:problemIds)
        ORDER BY o.problemId
    """)
    List<OptionResponse> findAllByProblemIdInIds(@Param("problemIds") List<Long> problemIds);
}
