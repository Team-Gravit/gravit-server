package gravit.code.userLeague.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.userLeague.dto.internal.LeagueRankRowDto;
import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
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
                - ACTIVE 시즌이 없거나 해당 페이지에 순위가 없으면 빈 목록을 반환합니다.<br>
                🔐 <strong>Jwt 필요</strong><br>
                🔐 <strong>다음 페이지가 존재하면 hasNextPage 가 true, 없으면 false</strong><br>
                """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 리그 랭킹 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = SliceResponse.class),
                            examples = @ExampleObject(
                                    name = "리그 랭킹 조회 성공 예시",
                                    value = """
                                            {
                                              "hasNextPage": true,
                                              "contents": [
                                                {
                                                  "rank": 1,
                                                  "userId": 12,
                                                  "lp": 1520,
                                                  "nickname": "학습자A",
                                                  "profileImgNumber": 3,
                                                  "xp": 4200,
                                                  "level": 7
                                                }
                                              ]
                                            }
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "예기치 못한 예외 발생",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping("/leagues/{leagueId}/page/{pageNum}")
    ResponseEntity<SliceResponse<LeagueRankRowDto>> getLeagueRanking(
            @Parameter(description = "리그 ID", example = "1")
            @PathVariable("leagueId") Long leagueId,
            @Parameter(description = "페이지 번호 (0-based)", example = "0")
            @PathVariable("pageNum") int pageNum
    );

    @Operation(
            summary = "내 리그 기준 유저 랭킹 조회 (페이지)",
            description = """
                인증된 사용자의 현재 리그를 기준으로 랭킹을 페이지 단위로 조회합니다.
                - `pageNum`은 0부터 시작하는 페이지 번호(0-based)입니다. <br>
                - 사용자의 리그 정보가 없거나 해당 페이지에 순위가 없으면 빈 목록을 반환합니다.<br>
                🔐 <strong>Jwt 필요</strong><br>
                🔐 <strong>다음 페이지가 존재하면 hasNextPage 가 true, 없으면 false</strong><br>
                """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 내 리그 랭킹 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = SliceResponse.class),
                            examples = @ExampleObject(
                                    name = "내 리그 랭킹 조회 성공 예시",
                                    value = """
                                            {
                                              "hasNextPage": true,
                                              "contents": [
                                                {
                                                  "rank": 1,
                                                  "userId": 12,
                                                  "lp": 1520,
                                                  "nickname": "학습자A",
                                                  "profileImgNumber": 3,
                                                  "xp": 4200,
                                                  "level": 7
                                                }
                                              ]
                                            }
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "예기치 못한 예외 발생",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping("/user-leagues/page/{pageNum}")
    ResponseEntity<SliceResponse<LeagueRankRowDto>> getLeagueRankingByUser(
            @Parameter(description = "페이지 번호 (0-based)", example = "0")
            @PathVariable("pageNum") int pageNum,
            @AuthenticationPrincipal LoginUser loginUser
    );

    @Operation(
            summary = "내 리그·랭킹 요약 조회",
            description = """
                    인증된 사용자의 현재 리그를 기준으로 랭킹 및 프로필 요약 정보를 반환합니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 내 리그, 랭킹 요약 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = MyLeagueRankWithProfileResponse.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 유저 리그 조회 실패",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "유저 리그 조회 실패",
                                    value = "{\"error\": \"U_L_4041\", \"message\": \"유저의 리그가 존재하지 않습니다\"}"
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "예기치 못한 예외 발생",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping("/me")
    ResponseEntity<MyLeagueRankWithProfileResponse> getMyLeagueWithProfile(
            @Parameter(hidden = true) @AuthenticationPrincipal LoginUser loginUser
    );
}
