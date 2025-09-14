package gravit.code.userLeague.controller.docs;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.userLeague.dto.response.LeagueRankRow;
import gravit.code.global.dto.SliceResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

@Tag(name = "League Rank API", description = "리그/사용자 기준 랭킹 조회 API")
public interface UserLeagueRankControllerDocs {

    @Operation(
            summary = "티어(리그)별 유저 랭킹 조회 (페이지)",
            description = """
                특정 리그의 랭킹을 페이지 단위로 조회합니다.<br>
                - `pageNum`은 0부터 시작하는 페이지 번호(0-based)입니다.<br>
                🔐 <strong>다음 페이지가 존재하면 hasNextPage 가 true, 없으면 false</strong><br>
                """,
            parameters = {
                    @Parameter(
                            name = "leagueId",
                            description = "리그 ID",
                            in = ParameterIn.PATH,
                            required = true,
                            example = "1"
                    ),
                    @Parameter(
                            name = "pageNum",
                            description = "페이지 번호 (0-based)",
                            in = ParameterIn.PATH,
                            required = true,
                            example = "0"
                    )
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "조회 성공",
                            content = @Content(
                                    mediaType = "application/json",
                                    array = @ArraySchema(schema = @Schema(implementation = LeagueRankRow.class))
                            )
                    ),
                    @ApiResponse(responseCode = "400", description = "잘못된 요청 파라미터"),
                    @ApiResponse(responseCode = "404", description = "리그를 찾을 수 없음"),
                    @ApiResponse(responseCode = "500", description = "서버 내부 에러")
            }
    )
    ResponseEntity<SliceResponse<LeagueRankRow>> getLeagueRanking(
            Long leagueId,
            int pageNum
    );

    @Operation(
            summary = "내 리그 기준 유저 랭킹 조회 (페이지)",
            description = """
                인증된 사용자의 현재 리그를 기준으로 랭킹을 페이지 단위로 조회합니다.
                - `pageNum`은 0부터 시작하는 페이지 번호(0-based)입니다. <br>
                🔐 <strong>Jwt 필요</strong><br>
                🔐 <strong>다음 페이지가 존재하면 hasNextPage 가 true, 없으면 false</strong><br>
                """,
            parameters = {
                    @Parameter(
                            name = "pageNum",
                            description = "페이지 번호 (0-based)",
                            in = ParameterIn.PATH,
                            required = true,
                            example = "0"
                    )
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "조회 성공",
                            content = @Content(
                                    mediaType = "application/json",
                                    array = @ArraySchema(schema = @Schema(implementation = LeagueRankRow.class))
                            )
                    ),
                    @ApiResponse(responseCode = "401", description = "인증 실패"),
                    @ApiResponse(responseCode = "404", description = "사용자 또는 리그를 찾을 수 없음"),
                    @ApiResponse(responseCode = "500", description = "서버 내부 에러")
            }
    )
    ResponseEntity<SliceResponse<LeagueRankRow>> getLeagueRankingByUser(
            int pageNum,
            @AuthenticationPrincipal LoginUser loginUser
    );

}
