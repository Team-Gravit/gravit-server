package gravit.code.notification.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.notification.dto.response.NotificationResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Notification API", description = "알림 인박스 조회")
public interface NotificationDocs {

    @Operation(
            summary = "알림 인박스 조회",
            description = """
                    로그인 유저의 알림 목록을 최신순으로 반환합니다. (20개/페이지)

                    **actionType 결정 규칙:**
                    - FOLLOW 타입: 현재 팔로우 관계 기준으로 동적 결정
                      - 상대를 아직 팔로우하지 않음 → `FOLLOW_BACK` (맞팔로우 버튼)
                      - 상대를 이미 팔로우 중 → `UNFOLLOW` (팔로우 취소 버튼)
                    - 나머지 타입: 알림 타입에 고정된 actionType 반환
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 조회 성공",
                    content = @Content(
                            mediaType = "application/json",
                            examples = @ExampleObject(
                                    name = "inbox-sample",
                                    value = """
                                            {
                                              "hasNextPage": true,
                                              "contents": [
                                                {
                                                  "id": 101,
                                                  "type": "FOLLOW",
                                                  "message": "홍길동님이 나를 팔로우했어요! 👀",
                                                  "actionType": "FOLLOW_BACK",
                                                  "targetId": 42,
                                                  "read": false,
                                                  "createdAt": "2025-09-25T10:00:00"
                                                },
                                                {
                                                  "id": 100,
                                                  "type": "FOLLOW",
                                                  "message": "김철수님이 나를 팔로우했어요! 👀",
                                                  "actionType": "UNFOLLOW",
                                                  "targetId": 37,
                                                  "read": true,
                                                  "createdAt": "2025-09-24T08:30:00"
                                                },
                                                {
                                                  "id": 99,
                                                  "type": "FRIEND_ACTIVITY",
                                                  "message": "이영희님이 OS행성을 정복했어요! 🌍",
                                                  "actionType": "CONGRATULATE",
                                                  "targetId": 55,
                                                  "read": false,
                                                  "createdAt": "2025-09-23T20:15:00"
                                                }
                                              ]
                                            }
                                            """
                            )
                    )
            )
    })
    @GetMapping
    ResponseEntity<SliceResponse<NotificationResponse>> getInbox(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "0부터 시작하는 페이지 번호", example = "0")
            @RequestParam(defaultValue = "0") int page
    );
}
