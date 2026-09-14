package gravit.code.league.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.league.dto.response.LeagueHomeResponse;
import gravit.code.league.dto.response.LeagueResponse;
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

@Tag(name = "League API", description = "리그 관련 API")
public interface LeagueControllerDocs {

    @Operation(
            summary = "리그 단건 조회",
            description = "리그 ID로 리그 정보를 조회합니다<br> " +
                    "<strong>리그 단건 조회는 현재 디자인상 사용하지 않아도 됩니다</strong><br>" +
                    "🔐 <strong>Jwt 필요</strong><br>"
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 리그 조회 성공"),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 리그 조회 실패(미존재)",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = {
                                    @ExampleObject(
                                            name = "리그 없음",
                                            value = "{\"error\":\"LEAGUE_4041\",\"message\":\"리그 조회에 실패하였습니다.\"}"
                                    )
                            }
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = {
                                    @ExampleObject(
                                            name = "서버 에러",
                                            value = "{\"error\":\"GLOBAL_5001\",\"message\":\"예기치 못한 예외 발생\"}"
                                    )
                            }
                    )
            )
    })
    @GetMapping("/{leagueId}")
    ResponseEntity<LeagueResponse> getLeague(
            @Parameter(description = "리그 ID", example = "1")
            @PathVariable("leagueId") Long leagueId
    );

    @Operation(
            summary = "리그 페이지 home 조회",
            description = "리그 페이지에 필요한 시즌 정보 및 팝업 데이터를 리턴합니다.<br> 시즌 정보는 필수적으로 포함합니다<br> " +
                    "containsPopup 필드가 true 면, lastSeasonPopup 에 팝업 정보를 포함합니다. <br> " +
                    "containsPopup 필드가 false 면, lastSeasonPopup 은 null 값을 가집니다.<br>" +
                    "🔐 <strong>Jwt 필요</strong><br>"
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 리그 home 조회 성공"),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 시즌 조회 실패(미존재)",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = {
                                    @ExampleObject(
                                            name = "ACTIVE 시즌 없음",
                                            value = "{\"error\":\"SEASON_4041\",\"message\":\"ACTIVE 시즌이 없습니다.\"}"
                                    )
                            }
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = {
                                    @ExampleObject(
                                            name = "서버 에러",
                                            value = "{\"error\":\"GLOBAL_5001\",\"message\":\"예기치 못한 예외 발생\"}"
                                    )
                            }
                    )
            )
    })
    @GetMapping("/home")
    ResponseEntity<LeagueHomeResponse> enterHome(@AuthenticationPrincipal LoginUser loginUser);
}
