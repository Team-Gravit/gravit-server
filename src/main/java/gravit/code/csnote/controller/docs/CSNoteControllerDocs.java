package gravit.code.csnote.controller.docs;

import gravit.code.global.exception.domain.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Tag(name = "CS-Note API", description = "개념 노트 관련 API")
public interface CSNoteControllerDocs {

    @Operation(
            summary = "개념 노트 조회",
            description = "유닛에 지정된 개념 노트를 Markdown 형식으로 조회합니다. <br>" +
                    "응답 본문은 Markdown 텍스트 데이터입니다."
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 개념 노트 조회 성공",
                    content = @Content(
                            mediaType = "text/markdown",
                            schema = @Schema(type = "string", format = "binary"),
                            examples = @ExampleObject(
                                    name = "Markdown 응답 예시",
                                    value = "## 제목\n\n### 소제목\n\n본문 내용..."
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 유닛이 없거나 해당 유닛의 개념 노트가 없음",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = {
                                    @ExampleObject(
                                            name = "유닛 없음",
                                            value = "{\"error\": \"UNIT_4041\", \"message\": \"유닛 조회에 실패하였습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "개념 노트 없음",
                                            value = "{\"error\": \"CS_NOTE_4041\", \"message\": \"개념 노트를 찾을 수 없습니다.\"}"
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
                            examples = @ExampleObject(
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping("/units/{unitId}")
    ResponseEntity<Resource> getNoteByUnitId(
            @Parameter(description = "유닛 ID") @PathVariable("unitId") Long unitId
    );

    @Operation(
            summary = "개념 노트 조회 (deprecated)",
            description = "GET /api/v1/cs-notes/units/{unitId} 로 대체되었습니다. <br>" +
                    "동작은 대체 경로와 동일하며, 이 경로는 추후 제거됩니다.",
            deprecated = true
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 개념 노트 조회 성공",
                    content = @Content(
                            mediaType = "text/markdown",
                            schema = @Schema(type = "string", format = "binary"),
                            examples = @ExampleObject(
                                    name = "Markdown 응답 예시",
                                    value = "## 제목\n\n### 소제목\n\n본문 내용..."
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 유닛이 없거나 해당 유닛의 개념 노트가 없음",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = {
                                    @ExampleObject(
                                            name = "유닛 없음",
                                            value = "{\"error\": \"UNIT_4041\", \"message\": \"유닛 조회에 실패하였습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "개념 노트 없음",
                                            value = "{\"error\": \"CS_NOTE_4041\", \"message\": \"개념 노트를 찾을 수 없습니다.\"}"
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
                            examples = @ExampleObject(
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @Deprecated(forRemoval = true)
    @GetMapping("/{unitId}")
    ResponseEntity<Resource> getNote(
            @Parameter(description = "유닛 ID") @PathVariable("unitId") Long unitId
    );

}
