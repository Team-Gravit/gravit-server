package gravit.code.dailyLearningRecord.repository;

import gravit.code.dailyLearningRecord.domain.DailyLearningRecord;
import gravit.code.dailyLearningRecord.dto.response.DailySolvedCountResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

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

    @Query("""
            SELECT new gravit.code.dailyLearningRecord.dto.response.DailySolvedCountResponse(
                dlr.solvedDate, dlr.solvedLessonCount
            )
            FROM DailyLearningRecord dlr
            WHERE dlr.userId = :userId AND dlr.solvedDate BETWEEN :beginDate AND :endDate
            ORDER BY dlr.solvedDate ASC
    """)
    List<DailySolvedCountResponse> findDailySolvedCountsByUserIdBetween(
            @Param("userId") long userId,
            @Param("beginDate") LocalDate beginDate,
            @Param("endDate") LocalDate endDate
    );

    @Query("""
            SELECT dlr
            FROM DailyLearningRecord dlr
            WHERE dlr.userId = :userId AND dlr.solvedDate BETWEEN :thisMonday AND :thisSunday
            ORDER BY dlr.solvedDate
    """)
    List<DailyLearningRecord> findByUserIdAndSolvedDateBetween(
            @Param("userId") long userId,
            @Param("thisMonday") LocalDate thisMonday,
            @Param("thisSunday") LocalDate thisSunday
    );

    @Query("""
            SELECT dlr
            FROM DailyLearningRecord dlr
            WHERE dlr.userId = :userId AND dlr.solvedDate = :solvedDate
    """)
    Optional<DailyLearningRecord> findByUserIdAndSolvedDate(
            @Param("userId") long userId,
            @Param("solvedDate") LocalDate solvedDate
    );
}
