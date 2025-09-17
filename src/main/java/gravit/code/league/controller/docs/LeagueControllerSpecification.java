package gravit.code.league.controller.docs;

import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.league.dto.response.LeagueResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Tag(name = "League API", description = "리그 관련 API")
public interface LeagueControllerSpecification {

    @Operation(
            summary = "리그 단건 조회",
            description = "리그 ID로 리그 정보를 조회합니다"
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 리그 조회 성공"),
            @ApiResponse(
                    responseCode = "LEAGUE_4041",
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
                    responseCode = "GLOBAL_5001",
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
    ResponseEntity<LeagueResponse> getLeague(@PathVariable("leagueId") Long leagueId);
}
