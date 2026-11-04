package gravit.code.chapter.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.chapter.domain.ChapterCategory;
import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.global.exception.domain.ErrorResponse;
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

import java.util.List;

@Tag(name = "Chapter API", description = "챕터 관련 API")
public interface ChapterControllerDocs {

    @Operation(summary = "챕터 조회", description = "유저의 챕터 진행도를 포함한 챕터 목록을 조회합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 챕터 목록 조회 성공"),
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
    @GetMapping
    ResponseEntity<List<ChapterDetailResponse>> getAllChapter(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(
            summary = "CS 챕터 조회",
            description = """
                    CS 분류 챕터(자료구조, 알고리즘, 네트워크, 데이터베이스, 운영체제)를 유저의 진행도와 함께 챕터 id 순으로 조회합니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ CS 챕터 목록 조회 성공"),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "예기치 못한 예외 발생",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    ResponseEntity<List<ChapterDetailResponse>> getCsChapters(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(
            summary = "직군 옵션 조회",
            description = """
                    직군별 챕터 조회에서 고를 수 있는 직군 분류를 노출 순서대로 반환합니다. CS는 포함하지 않습니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 직군 옵션 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "직군 옵션 예시",
                                    value = """
                                            ["COMMON", "SERVER", "WEB", "AOS", "IOS", "LANGUAGE"]
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "예기치 못한 예외 발생",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    ResponseEntity<List<ChapterCategory>> getTracks(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(
            summary = "직군별 챕터 조회",
            description = """
                    선택한 직군 분류의 챕터를 유저의 진행도와 함께 챕터 id 순으로 조회합니다.<br>
                    직군 값은 직군 옵션 조회 결과(COMMON, SERVER, WEB, AOS, IOS, LANGUAGE)를 그대로 씁니다. CS는 CS 챕터 조회를 사용하세요.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 직군별 챕터 목록 조회 성공"),
            @ApiResponse(
                    responseCode = "400",
                    description = "🚨 직군이 아닌 분류(CS) 요청, 존재하지 않는 분류 값 요청",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = {
                                    @ExampleObject(
                                            name = "직군이 아닌 분류 요청",
                                            value = "{\"error\": \"CHAPTER_4001\", \"message\": \"직군 분류만 조회할 수 있습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "존재하지 않는 분류 값 요청",
                                            value = "{\"error\": \"GLOBAL_4001\", \"message\": \"유효성 검사 실패\"}"
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
                                    name = "예기치 못한 예외 발생",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    ResponseEntity<List<ChapterDetailResponse>> getTrackChapters(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "직군 분류", example = "SERVER") @PathVariable ChapterCategory track
    );
}
