package gravit.code.fcm.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.fcm.dto.request.RegisterFcmTokenRequest;
import gravit.code.fcm.dto.response.FcmTokenExistsResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "FCM Token API", description = "FCM 디바이스 토큰 등록/갱신 API")
public interface FcmTokenControllerDocs {

    @Operation(summary = "FCM 토큰 등록 및 갱신", description = """
            클라이언트 디바이스의 FCM 토큰을 등록하거나 갱신합니다.<br>
            🔐 <strong>Jwt 필요</strong><br>
            <strong>멱등</strong>하게 동작합니다: deviceId 기준으로<br>
            - 등록 내역이 없으면 신규 저장<br>
            - 있으면 토큰을 갱신하고 소유자를 현재 사용자로 이전(기기 공유·재로그인 대응)<br>
            클라이언트는 앱 시작/로그인 직후 호출하면 됩니다.
            """)
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 토큰 등록/갱신 성공"),
            @ApiResponse(responseCode = "400", description = "🚨 요청 값 검증 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "필수 값 누락",
                                            value = "{\"error\" : \"GLOBAL_4001\", \"message\" : [\"[ deviceId ][ 디바이스 아이디가 비어있습니다. ][ null ]\"]}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
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
    ResponseEntity<Void> registerFcmToken(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody RegisterFcmTokenRequest request
    );

    @Operation(summary = "FCM 토큰 등록 여부 확인", description = """
            현재 사용자가 해당 디바이스에 FCM 토큰을 등록했는지 확인합니다.<br>
            🔐 <strong>Jwt 필요</strong><br>
            클라이언트는 앱 시작 시 호출해 등록 여부(registered)를 확인하고,<br>
            미등록(false)이면 등록 API를 호출하면 됩니다.
            """)
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 확인 성공",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = FcmTokenExistsResponse.class),
                            examples = {
                                    @ExampleObject(name = "등록됨", value = "{\"registered\": true}"),
                                    @ExampleObject(name = "미등록", value = "{\"registered\": false}")
                            })
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
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
    @GetMapping("/exists")
    ResponseEntity<FcmTokenExistsResponse> checkFcmTokenExist(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "클라이언트 디바이스 식별자", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890", required = true)
            @NotBlank(message = "디바이스 아이디가 비어있습니다.")
            @RequestParam("deviceId") String deviceId
    );
}
