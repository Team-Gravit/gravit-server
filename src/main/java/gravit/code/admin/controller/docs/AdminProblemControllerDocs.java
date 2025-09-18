package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.ProblemCreateRequest;
import gravit.code.admin.dto.request.ProblemUpdateRequest;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.learning.dto.response.ProblemResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Admin Problem API", description = "관리자 문제 관리 API")
public interface AdminProblemControllerDocs {

    @Operation(summary = "문제 조회", description = "특정 문제의 상세 정보를 조회합니다<br>" +
            "🔐 <strong>관리자 권한 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 문제 조회 성공"),
            @ApiResponse(responseCode = "PROBLEM_4041", description = "🚨 문제 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "문제 조회 실패",
                                            value = "{\"error\" : \"PROBLEM_4041\", \"message\" : \"문제 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "GLOBAL_5001", description = "🚨 예기치 못한 예외 발생",
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
    @GetMapping("/{problemId}")
    ResponseEntity<ProblemResponse> getProblem(@PathVariable("problemId") Long problemId);

    @Operation(summary = "문제 생성", description = "새로운 문제를 생성합니다<br>" +
            "🔐 <strong>관리자 권한 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "✅ 문제 생성 성공"),
            @ApiResponse(responseCode = "GLOBAL_4001", description = "🚨 유효성 검사 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효성 검사 실패",
                                            value = "{\"error\" : \"GLOBAL_4001\", \"message\" : \"유효성 검사 실패\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "GLOBAL_5001", description = "🚨 예기치 못한 예외 발생",
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
    @PostMapping
    ResponseEntity<Void> createProblem(@Valid @RequestBody ProblemCreateRequest request);

    @Operation(summary = "문제 수정", description = "기존 문제를 수정합니다<br>" +
            "🔐 <strong>관리자 권한 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "✅ 문제 수정 성공"),
            @ApiResponse(responseCode = "PROBLEM_4041", description = "🚨 문제 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "문제 조회 실패",
                                            value = "{\"error\" : \"PROBLEM_4041\", \"message\" : \"문제 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "GLOBAL_4001", description = "🚨 유효성 검사 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유효성 검사 실패",
                                            value = "{\"error\" : \"GLOBAL_4001\", \"message\" : \"유효성 검사 실패\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "GLOBAL_5001", description = "🚨 예기치 못한 예외 발생",
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
    @PutMapping
    ResponseEntity<Void> updateProblem(@Valid @RequestBody ProblemUpdateRequest request);

    @Operation(summary = "문제 삭제", description = "기존 문제를 삭제합니다<br>" +
            "🔐 <strong>관리자 권한 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "✅ 문제 삭제 성공"),
            @ApiResponse(responseCode = "PROBLEM_4041", description = "🚨 문제 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "문제 조회 실패",
                                            value = "{\"error\" : \"PROBLEM_4041\", \"message\" : \"문제 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "GLOBAL_5001", description = "🚨 예기치 못한 예외 발생",
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
    @DeleteMapping("/{problemId}")
    ResponseEntity<Void> deleteProblem(@PathVariable("problemId") Long problemId);
}
