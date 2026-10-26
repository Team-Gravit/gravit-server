package gravit.code.test.season.docs;

import gravit.code.test.season.dto.response.TestSeasonPopupResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Test Season Popup API", description = "[QA 전용] 특정 유저가 시즌 결과·시즌 시작 팝업을 다시 보게 만드는 테스트 API")
public interface TestSeasonPopupControllerDocs {

    @Operation(
            summary = "[테스트] 시즌 팝업 다시 보기",
            description = "가장 최근 CLOSED 시즌을 Redis lastClosedSeasonId 로 기록하고, 해당 유저의 season:seen 키를 지웁니다.<br>"
                    + "유저가 그 시즌의 user_league_history 와 현재 시즌 user_league 를 갖고 있어야 다음 <code>GET /api/v1/league/home</code> 에서 "
                    + "<code>containsPopup=true</code> 가 옵니다(QA 페르소나 <code>league-edge</code> 가 해당). 다른 유저에게는 영향이 없습니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 기록 완료 — hasLeagueHistory 가 false 면 이력이 없어 팝업이 뜨지 않음"),
            @ApiResponse(responseCode = "404", description = "❌ 유저가 없음(USER_4041) 또는 CLOSED 시즌이 없음")
    })
    @PostMapping("/season/popup")
    ResponseEntity<TestSeasonPopupResponse> resetSeasonPopup(
            @Parameter(description = "팝업을 다시 보게 할 유저 id", example = "123", required = true)
            @RequestParam Long userId
    );
}
