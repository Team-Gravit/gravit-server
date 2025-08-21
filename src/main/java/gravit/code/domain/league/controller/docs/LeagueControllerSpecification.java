package gravit.code.domain.league.controller.docs;

import gravit.code.domain.league.dto.response.LeagueResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
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
    })
    @GetMapping("/{leagueId}")
    ResponseEntity<LeagueResponse> getLeague(@PathVariable("leagueId") Long leagueId);
}
