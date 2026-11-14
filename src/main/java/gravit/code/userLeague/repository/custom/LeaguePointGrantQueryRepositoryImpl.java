package gravit.code.userLeague.repository.custom;

import gravit.code.userLeague.dto.internal.UngrantedLessonSubmissionDto;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static gravit.code.userLeague.repository.sql.LeaguePointGrantQuerySql.FIND_UNGRANTED_FIRST_LESSON_SUBMISSIONS;

@RequiredArgsConstructor
@Repository
public class LeaguePointGrantQueryRepositoryImpl implements LeaguePointGrantQueryRepository {

    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Override
    public List<UngrantedLessonSubmissionDto> findUngrantedFirstLessonSubmissions(
            LocalDateTime since,
            LocalDateTime until,
            int limit
    ) {
        Map<String, Object> params = Map.of(
                "since", since,
                "until", until,
                "limit", limit
        );

        return jdbcTemplate.query(
                FIND_UNGRANTED_FIRST_LESSON_SUBMISSIONS,
                params,
                (rs, rowNum) -> new UngrantedLessonSubmissionDto(
                        rs.getLong("user_id"),
                        rs.getLong("lesson_id"),
                        rs.getInt("accuracy")
                )
        );
    }
}
