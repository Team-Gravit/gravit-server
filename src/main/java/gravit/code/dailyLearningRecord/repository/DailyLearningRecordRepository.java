package gravit.code.dailyLearningRecord.repository;

import gravit.code.dailyLearningRecord.domain.DailyLearningRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface DailyLearningRecordRepository extends JpaRepository<DailyLearningRecord, Long> {

    @Query("""
        SELECT dlr.solvedDate
        FROM DailyLearningRecord dlr
        WHERE dlr.userId = :userId AND dlr.solvedDate BETWEEN :startDate AND :endDate
    """)
    List<LocalDate> findSolvedDatesByUserIdAndDateRange(
            @Param("userId") long userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );
}
