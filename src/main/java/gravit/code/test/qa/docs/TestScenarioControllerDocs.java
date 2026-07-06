package gravit.code.test.qa.docs;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Test Scenario API", description = "[QA 전용] 특정 학습 상태(챕터 거의 클리어·연속학습)를 강제로 만들어 주는 시나리오 세팅 API")
public interface TestScenarioControllerDocs {

    @Operation(
            summary = "[테스트] 챕터 거의 클리어 상태 생성",
            description = "지정 유저에게 해당 챕터의 레슨을 마지막 몇 개만 남기고 전부 제출 처리합니다.<br>"
                    + "챕터 완료 직전 상태(보상/승급 등)를 테스트할 때 사용합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 세팅 성공 (userId 반환)")
    })
    @PostMapping("/chapter-almost-clear")
    ResponseEntity<Long> createChapterAlmostClearUser(
            @Parameter(description = "대상 유저 ID", example = "1")
            @RequestParam Long userId,
            @Parameter(description = "거의 클리어 상태로 만들 챕터 ID", example = "1")
            @RequestParam Long chapterId
    );

    @Operation(
            summary = "[테스트] 연속학습 일수 강제 세팅",
            description = "지정 유저의 Learning 연속학습 일수(consecutiveSolvedDays)를 지정 값으로 설정하고 오늘 미해결(todaySolved=false) 상태로 만듭니다.<br>"
                    + "연속학습 끊길 위기 알림 등 연속학습 기반 로직을 테스트할 때 사용합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 세팅 성공 (userId 반환)")
    })
    @PostMapping("/consecutive_solved")
    ResponseEntity<Long> testConsecutiveSolvedUser(
            @Parameter(description = "대상 유저 ID", example = "1")
            @RequestParam Long userId,
            @Parameter(description = "설정할 연속학습 일수", example = "7")
            @RequestParam int consecutiveSolvedCount
    ) throws Exception;
}
