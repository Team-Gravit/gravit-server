package gravit.code.userLeague.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class LeagueRankQuerySql {

    /**
     * 랭킹 저장소 미스 시 사용하는 단건 순위 폴백
     * - 나보다 앞선 사람 수 + 1 로 구한다
     * - 동점자는 user_id 오름차순으로 앞선다(저장소의 점수 인코딩과 동일)
     **/
    public static final String FIND_RANK_IN_LEAGUE_SQL = """
            SELECT 1 + COUNT(*)
            FROM user_league ul
            JOIN users u ON u.id = ul.user_id
            WHERE ul.season_id = :seasonId
              AND ul.league_id = :leagueId
              AND u.deleted_at IS NULL
              AND (
                ul.league_point > :leaguePoint
                OR (ul.league_point = :leaguePoint AND ul.user_id < :userId)
              )
            """;

    /**
     * 랭킹 저장소 장애 시 사용하는 리그 내 순위 페이지 폴백
     * - 정렬 기준은 저장소의 점수 인코딩과 동일하다(리그 점수 내림차순, 동점은 user_id 오름차순)
     * - 순위는 조회하지 않고 offset 기준으로 매긴다(저장소의 findPage와 동일한 방식)
     **/
    public static final String FIND_RANK_PAGE_IN_LEAGUE_SQL = """
            SELECT ul.user_id,
                   ul.league_point
            FROM user_league ul
            JOIN users u ON u.id = ul.user_id
            WHERE ul.season_id = :seasonId
              AND ul.league_id = :leagueId
              AND u.deleted_at IS NULL
            ORDER BY ul.league_point DESC, ul.user_id ASC
            LIMIT :limit OFFSET :offset
            """;
}
