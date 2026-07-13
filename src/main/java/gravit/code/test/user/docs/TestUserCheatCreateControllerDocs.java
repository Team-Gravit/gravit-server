package gravit.code.test.user.docs;

import gravit.code.auth.dto.response.LoginResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Test User Cheat API", description = "[QA 전용] 유저 생성·로그인·팔로우 관계·이벤트 발행 등 테스트 상태를 임의로 세팅하는 API")
public interface TestUserCheatCreateControllerDocs {

    @Operation(
            summary = "[테스트] 치트 유저 생성",
            description = "이메일/닉네임/권한으로 유저를 즉시 생성하고 온보딩까지 완료한 뒤 토큰을 반환합니다.<br>"
                    + "실제 서버 제약과 동일하게 이메일·권한(ADMIN/USER)·닉네임(2~8자, 한글/영문/숫자)을 검증합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 생성 성공 (로그인 토큰 반환)"),
            @ApiResponse(responseCode = "400", description = "🚨 입력값(이메일/권한/닉네임) 검증 실패")
    })
    @PostMapping("/users/create")
    ResponseEntity<LoginResponse> createUser(
            @Parameter(description = "유저 이메일", example = "test@gravit.com")
            @RequestParam String email,
            @Parameter(description = "닉네임(2~8자, 한글/영문/숫자)", example = "테스트유저")
            @RequestParam String nickname,
            @Parameter(description = "권한(ADMIN/USER)", example = "USER")
            @RequestParam String role
    );

    @Operation(
            summary = "[테스트] 1번 유저 기준 팔로우 관계 세팅",
            description = "1번 유저 기준으로 팔로우 관계를 구성합니다.<br>"
                    + "2~10번: 맞팔로우 / 11~19번: 1번을 팔로잉 / 20번: 관계 없음."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 세팅 성공")
    })
    @PostMapping("/follows/setup")
    ResponseEntity<Void> setupFollowRelations();

    @Operation(
            summary = "[테스트] 공지 생성 이벤트 발행",
            description = "NoticeCreatedEvent 를 발행해 실제 알림 경로(NotificationEventListener)를 태웁니다.<br>"
                    + "⚠️ 리스너가 NOTICE 알림을 <strong>전체 활성 유저</strong>에게 브로드캐스트 적재하므로 공유 환경에서는 주의하세요."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 이벤트 발행 성공")
    })
    @PostMapping("/events/notice-created")
    ResponseEntity<Void> publishNoticeCreatedEvent(
            @Parameter(description = "딥링크 대상 공지 ID", example = "1")
            @RequestParam long noticeId,
            @Parameter(description = "서브텍스트로 노출될 공지 제목", example = "테스트 공지")
            @RequestParam String title
    );

    @Operation(
            summary = "[테스트] userId 로 로그인 토큰 발급",
            description = "지정 userId 의 유저로 로그인 토큰(access/refresh)을 즉시 발급합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발급 성공 (로그인 토큰 반환)")
    })
    @PostMapping("/users/login")
    ResponseEntity<LoginResponse> login(
            @Parameter(description = "로그인할 유저 ID", example = "1")
            @RequestParam Long userId
    );

    @Operation(
            summary = "[테스트] 커스텀 만료시간 토큰 발급",
            description = "기존 accessToken 의 유저로, 지정한 만료시간(분)을 가진 새 accessToken 을 발급합니다.<br>"
                    + "토큰 만료 관련 시나리오 테스트에 사용합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발급 성공 (로그인 토큰 반환)")
    })
    @PostMapping("/tokens/custom")
    ResponseEntity<LoginResponse> generateCustomToken(
            @Parameter(description = "기준이 되는 기존 accessToken")
            @RequestParam String accessToken,
            @Parameter(description = "새 토큰 만료시간(분)", example = "60")
            @RequestParam Long newExpirationMinutes
    );
}
