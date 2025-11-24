package gravit.code.option.infrastructure;

import gravit.code.option.dto.response.OptionResponse;
import gravit.code.option.domain.Option;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OptionJpaRepository extends JpaRepository<Option, Long> {

    @Query("""
        SELECT new gravit.code.option.dto.response.OptionResponse(o.id, o.content, o.explanation, o.isAnswer, o.problemId)
        FROM Option o
        WHERE o.problemId = :problemId
        ORDER BY o.problemId ASC
    """)
    List<OptionResponse> findByProblemId(@Param("problemId")long problemId);

    void deleteAllByProblemId(long problemId);
}
