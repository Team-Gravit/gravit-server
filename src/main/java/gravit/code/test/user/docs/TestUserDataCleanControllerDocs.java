package gravit.code.test.user.docs;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Test User Clean API", description = "[QA 전용] 이메일로 식별된 유저와 연관 데이터를 전부 삭제하는 테스트 API")
public interface TestUserDataCleanControllerDocs {

    @Operation(
            summary = "[테스트] 유저 및 연관 데이터 삭제",
            description = "해당 이메일을 가진 <strong>모든</strong> 유저(중복 가능)와 연관 데이터를 삭제합니다.<br>"
                    + "소셜/알림/문의/학습/리그/미션/면접 등 users 를 참조하는 데이터는 실제 탈퇴 정리와 같은 SQL로 삭제합니다.<br>"
                    + "일일 활동 기록(user_daily_activity)은 별도 DELETE로 삭제하고, Redis 리그 랭킹 항목은 랭킹 제거 이벤트로 커밋 후 정리합니다.<br>"
                    + "삭제된 유저 수를 문자열로 반환하며, 대상이 없으면 404를 반환합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 삭제 성공 (삭제된 유저 수 반환)"),
            @ApiResponse(responseCode = "404", description = "🚨 해당 이메일의 유저 없음")
    })
    @PostMapping("/users/clean")
    ResponseEntity<String> clean(
            @Parameter(description = "삭제 대상 유저의 이메일", example = "test@gravit.com")
            @RequestParam String email
    );
}
