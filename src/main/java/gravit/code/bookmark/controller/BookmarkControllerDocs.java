package gravit.code.bookmark.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.bookmark.dto.request.BookmarkDeleteRequest;
import gravit.code.bookmark.dto.request.BookmarkSaveRequest;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.problem.dto.response.BookmarkedProblemResponse;
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
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Bookmark API", description = "북마크 관련 API")
public interface BookmarkControllerDocs {

    @Operation(summary = "유닛 내 북마크된 문제 조회", description = "특정 유닛에서 사용자가 북마크한 문제 목록을 조회합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 북마크된 문제 목록 조회 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 유닛 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유닛 조회 실패",
                                            value = "{\"error\" : \"UNIT_4041\", \"message\" : \"유닛 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 정답 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "정답 조회 실패",
                                            value = "{\"error\" : \"ANSWER_4041\", \"message\" : \"정답 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
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
    @GetMapping("/{unitId}")
    ResponseEntity<BookmarkedProblemResponse> getAllBookmarkedProblemInUnit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("unitId") Long unitId
    );

    @Operation(summary = "북마크 저장", description = "특정 문제를 북마크에 추가합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 북마크 저장 성공"),
            @ApiResponse(responseCode = "409", description = "🚨 이미 북마크한 문제",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "북마크 중복",
                                            value = "{\"error\" : \"BOOKMARK_4091\", \"message\" : \"이미 북마크한 문제입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping
    ResponseEntity<Void> addBookmark(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody BookmarkSaveRequest request
    );

    @Operation(summary = "북마크 삭제", description = "특정 문제의 북마크를 삭제합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "✅ 북마크 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 북마크 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "북마크 조회 실패",
                                            value = "{\"error\" : \"BOOKMARK_4041\", \"message\" : \"북마크 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @DeleteMapping
    ResponseEntity<Void> deleteBookmark(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody BookmarkDeleteRequest request
    );
}
