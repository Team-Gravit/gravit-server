package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.NoticeCreateRequest;
import gravit.code.admin.dto.request.NoticeUpdateRequest;
import gravit.code.admin.dto.response.NoticeResponse;
import gravit.code.auth.oauth.LoginUser;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "Admin Notice Command API", description = "관리자 공지 생성/수정/삭제")
public interface AdminNoticeCommandControllerDocs {

    @Operation(
            summary = "공지 생성",
            description = "관리자 권한으로 공지를 생성합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "✅ 공지 생성 성공",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = NoticeResponse.class)))
    })
    @PostMapping("/create")
    ResponseEntity<NoticeResponse> createNotice(@AuthenticationPrincipal LoginUser loginUser,
                                                @RequestBody NoticeCreateRequest noticeCreateResponse);

    @Operation(
            summary = "공지 수정",
            description = "관리자 권한으로 공지를 수정합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "✅ 공지 수정 성공",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = NoticeResponse.class)))
    })
    @PostMapping("/update")
    ResponseEntity<NoticeResponse> updateNotice(@AuthenticationPrincipal LoginUser loginUser,
                                                @RequestBody NoticeUpdateRequest noticeUpdateRequest);

    @Operation(
            summary = "공지 삭제",
            description = "관리자 권한으로 공지를 삭제합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 공지 삭제 성공"),

    })
    @DeleteMapping("/delete/{noticeId}")
    ResponseEntity<Void> deleteNotice(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("noticeId") Long noticeId
    );
}
