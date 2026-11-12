package gravit.code.test.fixture.docs;

import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.test.fixture.dto.response.QaFixtureManifestResponse;
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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Test QA Fixture API", description = "[QA 전용] gravit-qa 페르소나 데이터셋을 세트별로 지우고 다시 적재하는 API")
public interface TestQaFixtureControllerDocs {

    @Operation(
            summary = "[테스트] QA 페르소나 세트 재적재",
            description = "세트(auto, manual)의 페르소나 13개와 보조 유저를 지우고 `sql/seed/qa/` 데이터셋으로 다시 적재한 뒤, "
                    + "리그 랭킹과 탈퇴 정리 예약(Redis)을 맞추고 페르소나별 userId 매니페스트를 반환합니다.<br>"
                    + "다른 세트의 데이터는 건드리지 않습니다. userId는 재적재마다 바뀝니다.<br>"
                    + "페르소나 명세는 `sql/seed/qa/PERSONAS.md`를 참고하세요."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 재적재 성공 (매니페스트 반환)"),
            @ApiResponse(responseCode = "400", description = "🚨 지원하지 않는 세트",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "지원하지 않는 세트",
                                            value = "{\"error\" : \"QA_FIXTURE_4001\", \"message\" : \"지원하지 않는 QA 페르소나 세트입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 ACTIVE 시즌 없음",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "ACTIVE 시즌 없음",
                                            value = "{\"error\" : \"SEASON_4041\", \"message\" : \"ACTIVE 시즌이 없습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "409", description = "🚨 같은 세트 재적재 진행 중, 기준 데이터 부족",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "같은 세트 재적재 진행 중",
                                            value = "{\"error\" : \"QA_FIXTURE_4091\", \"message\" : \"같은 세트의 재적재가 진행 중입니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "기준 데이터 부족",
                                            value = "{\"error\" : \"QA_FIXTURE_4092\", \"message\" : \"QA 페르소나 적재에 필요한 기준 데이터가 없습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/reload")
    ResponseEntity<QaFixtureManifestResponse> reload(
            @Parameter(description = "재적재할 세트 (auto | manual)", example = "auto")
            @RequestParam String set
    );
}
