package gravit.code.notification.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.notification.dto.response.NotificationResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Tag(name = "Notification API", description = "알림 인박스 조회")
public interface NotificationDocs {

    @Operation(
            summary = "알림 인박스 조회",
            description = """
                    로그인 유저의 알림 목록을 최신순으로 반환합니다.
                    최근 30일 이내 알림 중 최신 30건까지 단일 목록으로 반환합니다(페이지네이션 없음).

                    **actionType 결정 규칙:**
                    - FOLLOW 타입: 현재 팔로우 관계 기준으로 동적 결정
                      - 상대를 아직 팔로우하지 않음 → `FOLLOW_BACK` (맞팔로우 버튼)
                      - 상대를 이미 팔로우 중 → `NONE` (버튼 없음)
                    - 나머지 타입: 알림 타입에 고정된 actionType 반환

                    **congratulated (축하 완료 여부):**
                    - FRIEND_ACTIVITY 타입에서만 값이 있으며(targetId=feedId), 그 외 타입은 null
                    - 해당 피드를 이미 축하했으면 true → 소셜 피드와 동일하게 '축하 완료' 상태로 노출
                    - 알림함/소셜 피드 어느 쪽에서 축하하든 동일 피드로 동기화됨(actionType은 `CONGRATULATE` 유지)
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 조회 성공"
            )
    })
    @GetMapping
    ResponseEntity<List<NotificationResponse>> getInbox(
            @AuthenticationPrincipal LoginUser loginUser
    );
}
