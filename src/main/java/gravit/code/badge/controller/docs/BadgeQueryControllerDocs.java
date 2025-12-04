package gravit.code.badge.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.badge.dto.response.AllBadgesResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;

@Tag(name = "Badge", description = "뱃지 조회 API")
public interface BadgeQueryControllerDocs {

    @Operation(
            summary = "내 뱃지 목록(카테고리별 정렬) 조회",
            description = """
                    전체 뱃지 카탈로그를 **카테고리 → 뱃지 display_order** 기준으로 정렬하여 반환합니다.<br>
                    각 뱃지에는 현재 유저가 획득했는지 여부(earned)가 포함됩니다.<br>
                    응답의 earnedCount / totalCount로 전체 대비 획득 개수를 확인할 수 있습니다.
                    """)
    @ApiResponse(
            responseCode = "200",
            description = "✅ 내 뱃지 목록 조회 성공",
            content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = AllBadgesResponse.class)
            )
    )
    @ApiResponse(
            responseCode = "500",
            description = "🚨 서버 오류",
            content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = ErrorResponse.class),
                    examples = {
                            @ExampleObject(
                                    name = "예기치 못한 예외",
                                    value = "{\"error\":\"GLOBAL_5001\",\"message\":\"예기치 못한 예외가 발생했습니다.\"}"
                            )
                    }
            )
    )
    @GetMapping("/me")
    ResponseEntity<AllBadgesResponse> getAllMyBadges(@AuthenticationPrincipal LoginUser loginUser);
}