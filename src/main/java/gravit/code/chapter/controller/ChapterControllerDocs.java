package gravit.code.chapter.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.chapter.dto.response.ChapterDetailResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Tag(name = "Chapter API", description = "챕터 관련 API")
public interface ChapterControllerDocs {

    @Operation(summary = "챕터 조회", description = "유저의 챕터 진행도를 포함한 챕터 목록을 조회합니다.<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 챕터 목록 조회 성공")
    })
    @GetMapping
    ResponseEntity<List<ChapterDetailResponse>> getAllChapter(@AuthenticationPrincipal LoginUser loginUser);
}
