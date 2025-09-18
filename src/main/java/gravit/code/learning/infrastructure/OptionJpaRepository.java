package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Option;
import gravit.code.learning.dto.response.OptionResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OptionJpaRepository extends JpaRepository<Option, Long> {

    @Query("""
        SELECT new gravit.code.learning.dto.response.OptionResponse(o.id, o.content, o.explanation, o.isAnswer, o.problemId)
        FROM Option o
        WHERE o.problemId IN (:problemIds)
        ORDER BY o.problemId
    """)
    List<OptionResponse> findAllByProblemIdInIds(@Param("problemIds") List<Long> problemIds);

    @Query("""
        SELECT new gravit.code.learning.dto.response.OptionResponse(o.id, o.content, o.explanation, o.isAnswer, o.problemId)
        FROM Option o
        WHERE o.problemId = :problemId
        ORDER BY o.problemId ASC
    """)
    List<OptionResponse> findByProblemId(@Param("problemId")Long problemId);

    void deleteAllByProblemId(Long problemId);
}
