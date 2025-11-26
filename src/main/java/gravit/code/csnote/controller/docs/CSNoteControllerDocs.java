package gravit.code.csnote.controller.docs;

import gravit.code.global.exception.domain.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
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
            description = "챕터와 유닛 정보로 Markdown 형식의 개념 노트를 조회합니다. <br>" +
                    "응답 본문은 Markdown 텍스트 데이터입니다. <br><br>" +
                    "**파일 구조**: static/notes/{chapter}/{unit}.md <br>" +
                    "**예시**: /api/v1/notes/algorithm/unit01 → static/notes/algorithm/unit01.md <br>" +
                    "**챕터 리스트** : [algorithm, data-structure, network] <br>" +
                    "**알고리즘 유닛 리스트** : unit01 ~ unit17 <br>" +
                    "**자료구조 유닛 리스트** : unit01 ~ unit10 <br>" +
                    "**네트워크 유닛 리스트** : unit01 ~ unit14"
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "개념 노트 조회 성공",
                    content = @Content(
                            mediaType = "text/markdown",
                            schema = @Schema(type = "string", format = "binary"),
                            examples = @ExampleObject(
                                    name = "Markdown 응답 예시",
                                    value = "# 제목\n\n## 소제목\n\n본문 내용..."
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "요청한 개념 노트를 찾을 수 없습니다.",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "파일 없음",
                                    value = "{\"error\": \"NOT_FOUND\", \"message\": \"요청한 노트를 찾을 수 없습니다.\"}"
                            ),
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "서버 내부 오류가 발생했습니다.",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "서버 오류",
                                    value = "{\"error\": \"INTERNAL_SERVER_ERROR\", \"message\": \"서버 오류가 발생했습니다.\"}"
                            ),
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            )
    })
    @GetMapping("/{chapter}/{unit}")
    ResponseEntity<Resource> getNote(
            @PathVariable("chapter") String chapter,
            @PathVariable("unit") String unit
    );

}
