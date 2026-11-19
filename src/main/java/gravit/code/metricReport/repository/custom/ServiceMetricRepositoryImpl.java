package gravit.code.metricReport.repository.custom;

import gravit.code.metricReport.dto.internal.InquiryItemDto;
import gravit.code.metricReport.dto.internal.InterviewMetricDto;
import gravit.code.metricReport.dto.internal.LessonMetricDto;
import gravit.code.metricReport.dto.internal.ReportItemDto;
import gravit.code.metricReport.dto.internal.RetentionDto;
import gravit.code.metricReport.dto.internal.TypeCountDto;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static gravit.code.metricReport.repository.sql.ServiceMetricSql.COUNT_DAILY_ACTIVITIES;
import static gravit.code.metricReport.repository.sql.ServiceMetricSql.COUNT_DISTINCT_ACTIVE_USERS;
import static gravit.code.metricReport.repository.sql.ServiceMetricSql.COUNT_INQUIRIES_BY_TYPE;
import static gravit.code.metricReport.repository.sql.ServiceMetricSql.COUNT_PENDING_INQUIRIES;
import static gravit.code.metricReport.repository.sql.ServiceMetricSql.COUNT_REPORTS_BY_TYPE;
import static gravit.code.metricReport.repository.sql.ServiceMetricSql.COUNT_SIGNUPS;
import static gravit.code.metricReport.repository.sql.ServiceMetricSql.FIND_INQUIRIES;
import static gravit.code.metricReport.repository.sql.ServiceMetricSql.FIND_INTERVIEW_METRIC;
import static gravit.code.metricReport.repository.sql.ServiceMetricSql.FIND_LESSON_METRIC;
import static gravit.code.metricReport.repository.sql.ServiceMetricSql.FIND_REPORTS;
import static gravit.code.metricReport.repository.sql.ServiceMetricSql.FIND_RETENTION;

@Repository
@RequiredArgsConstructor
public class ServiceMetricRepositoryImpl implements ServiceMetricRepository {

    private static final String PARAM_START_AT = "startAt";
    private static final String PARAM_END_AT = "endAt";
    private static final String PARAM_START_DATE = "startDate";
    private static final String PARAM_END_DATE = "endDate";
    private static final String PARAM_DAY_OFFSET = "dayOffset";
    private static final String PARAM_LIMIT = "limit";

    private static final RowMapper<RetentionDto> RETENTION_MAPPER = (rs, i) ->
            new RetentionDto(
                    rs.getLong("cohort_size"),
                    rs.getLong("retained_count")
            );

    private static final RowMapper<LessonMetricDto> LESSON_METRIC_MAPPER = (rs, i) ->
            new LessonMetricDto(
                    rs.getLong("submission_count"),
                    rs.getLong("learner_count"),
                    rs.getObject("average_accuracy", Double.class)
            );

    private static final RowMapper<InterviewMetricDto> INTERVIEW_METRIC_MAPPER = (rs, i) ->
            new InterviewMetricDto(
                    rs.getLong("started_count"),
                    rs.getLong("submitted_count"),
                    rs.getLong("graded_answer_count")
            );

    private static final RowMapper<TypeCountDto> TYPE_COUNT_MAPPER = (rs, i) ->
            new TypeCountDto(
                    rs.getString("type"),
                    rs.getLong("count")
            );

    private static final RowMapper<ReportItemDto> REPORT_ITEM_MAPPER = (rs, i) ->
            new ReportItemDto(
                    rs.getLong("id"),
                    rs.getString("report_type"),
                    rs.getLong("problem_id"),
                    rs.getObject("submitted_at", LocalDateTime.class)
            );

    private static final RowMapper<InquiryItemDto> INQUIRY_ITEM_MAPPER = (rs, i) ->
            new InquiryItemDto(
                    rs.getLong("id"),
                    rs.getString("type"),
                    rs.getString("title"),
                    rs.getObject("created_at", LocalDateTime.class)
            );

    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Override
    public long countSignups(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt
    ) {
        return queryForCount(COUNT_SIGNUPS, timeRangeParams(startAt, endExclusiveAt));
    }

    private long queryForCount(
            String sql,
            MapSqlParameterSource params
    ) {
        Long count = jdbcTemplate.queryForObject(sql, params, Long.class);
        return count == null ? 0L : count;
    }

    private MapSqlParameterSource timeRangeParams(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt
    ) {
        return new MapSqlParameterSource()
                .addValue(PARAM_START_AT, startAt)
                .addValue(PARAM_END_AT, endExclusiveAt);
    }

    @Override
    public long countDailyActivities(
            LocalDate startDate,
            LocalDate endDate
    ) {
        return queryForCount(COUNT_DAILY_ACTIVITIES, dateRangeParams(startDate, endDate));
    }

    private MapSqlParameterSource dateRangeParams(
            LocalDate startDate,
            LocalDate endDate
    ) {
        return new MapSqlParameterSource()
                .addValue(PARAM_START_DATE, startDate)
                .addValue(PARAM_END_DATE, endDate);
    }

    @Override
    public long countDistinctActiveUsers(
            LocalDate startDate,
            LocalDate endDate
    ) {
        return queryForCount(COUNT_DISTINCT_ACTIVE_USERS, dateRangeParams(startDate, endDate));
    }

    @Override
    public RetentionDto findRetention(
            LocalDate cohortStartDate,
            LocalDate cohortEndDate,
            int dayOffset
    ) {
        MapSqlParameterSource params = timeRangeParams(cohortStartDate.atStartOfDay(), cohortEndDate.plusDays(1).atStartOfDay())
                .addValue(PARAM_DAY_OFFSET, dayOffset);

        return jdbcTemplate.queryForObject(FIND_RETENTION, params, RETENTION_MAPPER);
    }

    @Override
    public LessonMetricDto findLessonMetric(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt
    ) {
        return jdbcTemplate.queryForObject(FIND_LESSON_METRIC, timeRangeParams(startAt, endExclusiveAt), LESSON_METRIC_MAPPER);
    }

    @Override
    public InterviewMetricDto findInterviewMetric(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt
    ) {
        return jdbcTemplate.queryForObject(FIND_INTERVIEW_METRIC, timeRangeParams(startAt, endExclusiveAt), INTERVIEW_METRIC_MAPPER);
    }

    @Override
    public List<TypeCountDto> countReportsByType(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt
    ) {
        return jdbcTemplate.query(COUNT_REPORTS_BY_TYPE, timeRangeParams(startAt, endExclusiveAt), TYPE_COUNT_MAPPER);
    }

    @Override
    public List<ReportItemDto> findReports(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt,
            int limit
    ) {
        MapSqlParameterSource params = timeRangeParams(startAt, endExclusiveAt)
                .addValue(PARAM_LIMIT, limit);

        return jdbcTemplate.query(FIND_REPORTS, params, REPORT_ITEM_MAPPER);
    }

    @Override
    public List<TypeCountDto> countInquiriesByType(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt
    ) {
        return jdbcTemplate.query(COUNT_INQUIRIES_BY_TYPE, timeRangeParams(startAt, endExclusiveAt), TYPE_COUNT_MAPPER);
    }

    @Override
    public long countPendingInquiries() {
        return queryForCount(COUNT_PENDING_INQUIRIES, new MapSqlParameterSource());
    }

    @Override
    public List<InquiryItemDto> findInquiries(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt,
            int limit
    ) {
        MapSqlParameterSource params = timeRangeParams(startAt, endExclusiveAt)
                .addValue(PARAM_LIMIT, limit);

        return jdbcTemplate.query(FIND_INQUIRIES, params, INQUIRY_ITEM_MAPPER);
    }
}
