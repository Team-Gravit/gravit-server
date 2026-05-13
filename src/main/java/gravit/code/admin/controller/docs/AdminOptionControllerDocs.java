package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.OptionCreateRequest;
import gravit.code.admin.dto.request.OptionUpdateRequest;
import gravit.code.global.exception.domain.ErrorResponse;
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
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "Admin Option API", description = "관리자 옵션 관리 API")
public interface AdminOptionControllerDocs {

    @Operation(summary = "옵션 생성", description = "새로운 옵션을 생성합니다<br>" +
            "🔐 <strong>관리자 권한 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "✅ 옵션 생성 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 문제 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "문제 조회 실패",
                                            value = "{\"error\" : \"PROBLEM_4041\", \"message\" : \"문제 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping
    ResponseEntity<Void> createOption(@Valid @RequestBody OptionCreateRequest request);

    @Operation(summary = "옵션 수정", description = "기존 옵션을 수정합니다<br>" +
            "🔐 <strong>관리자 권한 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "✅ 옵션 수정 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 옵션 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "옵션 조회 실패",
                                            value = "{\"error\" : \"OPTION_4041\", \"message\" : \"옵션 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PutMapping
    ResponseEntity<Void> updateOption(@Valid @RequestBody OptionUpdateRequest request);

    @Operation(summary = "옵션 삭제", description = "기존 옵션을 삭제합니다<br>" +
            "🔐 <strong>관리자 권한 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "✅ 옵션 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 옵션 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "옵션 조회 실패",
                                            value = "{\"error\" : \"OPTION_4041\", \"message\" : \"옵션 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
    })
    @DeleteMapping("/{optionId}")
    ResponseEntity<Void> deleteOption(@PathVariable("optionId") Long optionId);
}
