package gravit.code.userLeague.repository;

import gravit.code.userLeague.domain.LeaguePointGrant;
import gravit.code.userLeague.repository.custom.LeaguePointGrantQueryRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;

public interface LeaguePointGrantRepository extends JpaRepository<LeaguePointGrant, Long>, LeaguePointGrantQueryRepository {

    @Modifying
    @Query(value = """
            INSERT INTO league_point_grant (user_id, source_type, source_id, points, created_at)
            VALUES (:userId, :sourceType, :sourceId, :points, :now)
            ON CONFLICT (source_type, source_id, user_id) DO NOTHING
    """, nativeQuery = true)
    int insertIfAbsent(
            @Param("userId") long userId,
            @Param("sourceType") String sourceType,
            @Param("sourceId") long sourceId,
            @Param("points") int points,
            @Param("now") LocalDateTime now
    );
}
