package gravit.code.test.season.docs;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;

@Tag(name = "Test Season Clean API", description = "[QA 전용] 시즌/리그 상태를 초기 시즌(id=1) 기준으로 리셋하는 테스트 API")
public interface SeasonCleanControllerDocs {

    @Operation(
            summary = "[테스트] 시즌/리그 초기화",
            description = "user_league 를 시즌 1로 되돌리고, user_league_history 를 비우며, id≠1 시즌을 삭제합니다.<br>"
                    + "시즌 1의 status 를 ACTIVE 로 되돌리고, 시즌 관련 Redis 캐시(lastClosedSeasonId·season:seen:*)도 삭제합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 초기화 성공")
    })
    @PostMapping("/season/clean")
    ResponseEntity<Void> cleanSeason();
}
