package gravit.code.userLeagueHistory.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.league.dto.response.LeagueHistoryResponse;
import io.swagger.v3.oas.annotations.Operation;
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

@Tag(name = "League History API", description = "리그 히스토리 관련 API")
public interface LeagueHistoryControllerDocs {

    @Operation(
            summary = "내 리그 히스토리 조회",
            description = "현재 로그인한 유저의 시즌별 최종 티어 기록을 조회합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 내 리그 히스토리 조회 성공"),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 ACTIVE 시즌 없음",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "ACTIVE 시즌 없음",
                                    value = "{\"error\":\"SEASON_4041\",\"message\":\"ACTIVE 시즌이 없습니다.\"}"
                            )
                    )
            )
    })
    @GetMapping("/me")
    ResponseEntity<LeagueHistoryResponse> getMyLeagueHistory(
            @AuthenticationPrincipal LoginUser loginUser
    );
}
