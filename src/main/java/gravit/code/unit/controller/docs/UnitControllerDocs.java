package gravit.code.unit.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.unit.dto.response.UnitPageResponse;
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

@Tag(name = "Unit API", description = "유닛 관련 API")
public interface UnitControllerDocs {

    @Operation(summary = "유닛 조회", description = "유저의 유닛 진행도를 포함한 유닛 목록을 조회합니다.<br>" +
            "유닛 목록은 챕터 내 순서(<strong>displayOrder</strong>) 오름차순입니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 유닛 목록 조회 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 챕터 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "챕터 조회 실패",
                                            value = "{\"error\" : \"CHAPTER_4041\", \"message\" : \"챕터 조회에 실패하였습니다.\"}"
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
    @GetMapping("/{chapterId}")
    ResponseEntity<UnitPageResponse> getAllUnitInChapter(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "챕터 ID", example = "1")
            @PathVariable("chapterId") Long chapterId
    );
}
