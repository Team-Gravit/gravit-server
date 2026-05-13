package gravit.code.userLeague.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.userLeague.dto.internal.LeagueRankRowDto;
import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Tag(name = "UserLeague API", description = "리그/사용자 랭킹 및 프로필 조회 API")
public interface UserLeagueControllerDocs {

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
                                    array = @ArraySchema(schema = @Schema(implementation = LeagueRankRowDto.class))
                            )
                    ),
                    @ApiResponse(responseCode = "400", description = "잘못된 요청 파라미터"),
                    @ApiResponse(responseCode = "404", description = "리그를 찾을 수 없음"),
                    @ApiResponse(responseCode = "500", description = "서버 내부 에러")
            }
    )
    @GetMapping("/leagues/{leagueId}/page/{pageNum}")
    ResponseEntity<SliceResponse<LeagueRankRowDto>> getLeagueRanking(
            @PathVariable("leagueId") Long leagueId,
            @PathVariable("pageNum") int pageNum
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
                                    array = @ArraySchema(schema = @Schema(implementation = LeagueRankRowDto.class))
                            )
                    ),
                    @ApiResponse(responseCode = "401", description = "인증 실패"),
                    @ApiResponse(responseCode = "404", description = "사용자 또는 리그를 찾을 수 없음"),
                    @ApiResponse(responseCode = "500", description = "서버 내부 에러")
            }
    )
    @GetMapping("/user-leagues/page/{pageNum}")
    ResponseEntity<SliceResponse<LeagueRankRowDto>> getLeagueRankingByUser(
            @PathVariable("pageNum") int pageNum,
            @AuthenticationPrincipal LoginUser loginUser
    );

    @Operation(
            summary = "내 리그·랭킹 요약 조회",
            description = """
                    인증된 사용자의 현재 리그를 기준으로 랭킹 및 프로필 요약 정보를 반환합니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """,
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "조회 성공",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = MyLeagueRankWithProfileResponse.class)
                            )
                    ),
                    @ApiResponse(responseCode = "404", description = "🚨 유저 조회 실패",
                            content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                                    examples = @ExampleObject(
                                            name = "유저 조회 실패",
                                            value = "{\"error\":\"USER_4041\",\"message\":\"존재하지 않는 유저입니다.\"}"
                                    ),
                                    schema = @Schema(implementation = ErrorResponse.class))
                    ),
                    @ApiResponse(responseCode = "500", description = "서버 내부 에러")
            }
    )
    @GetMapping
    ResponseEntity<MyLeagueRankWithProfileResponse> getMyLeagueWithProfile(
            @Parameter(hidden = true) @AuthenticationPrincipal LoginUser loginUser
    );
}
