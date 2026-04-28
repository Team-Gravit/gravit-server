package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.AdminUserStatusUpdateRequest;
import gravit.code.admin.dto.response.AdminUserDetailResponse;
import gravit.code.admin.dto.response.AdminUserSummaryResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.UserStatus;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Admin User API", description = "백오피스 유저 관리 관련 API")
public interface AdminUserControllerDocs {

    @Operation(
            summary = "유저 목록 조회",
            description = """
                    백오피스 유저 관리 화면의 유저 목록을 페이지 단위로 조회합니다.<br>
                    - page: 1-based 페이지 번호 (기본값 1, 페이지당 10건, id DESC 정렬)<br>
                    - search: email/nickname/handle 부분 일치 검색 (대소문자 구분)<br>
                    - status: ACTIVE | SUSPENDED | DELETED (미지정 시 전체)<br>
                    - role: ADMIN | USER (미지정 시 전체)<br>
                    🔐 <strong>Jwt 필요 (role=ADMIN)</strong><br>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 유저 목록 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = PageResponse.class),
                            examples = @ExampleObject(
                                    name = "성공 예시",
                                    value = """
                                            {
                                              "page": 1,
                                              "totalPages": 25,
                                              "hasNext": true,
                                              "contents": [
                                                {
                                                  "userId": 1001,
                                                  "email": "user@example.com",
                                                  "nickname": "홍길동",
                                                  "handle": "gildong",
                                                  "role": "USER",
                                                  "status": "ACTIVE",
                                                  "createdAt": "2026-01-15"
                                                }
                                              ]
                                            }
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "예기치 못한 예외 발생",
                                    value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping
    ResponseEntity<PageResponse<AdminUserSummaryResponse>> getUsersSummary(
            @Parameter(description = "페이지 번호 (1-based, 기본값 1)") @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "email/nickname/handle 검색 키워드") @RequestParam(required = false) String search,
            @Parameter(description = "유저 상태 (ACTIVE | SUSPENDED | DELETED)") @RequestParam(required = false) UserStatus status,
            @Parameter(description = "유저 권한 (ADMIN | USER)") @RequestParam(required = false) Role role
    );

    @Operation(
            summary = "유저 상세 조회",
            description = """
                    백오피스 유저 관리 화면에서 특정 유저의 상세 정보를 조회합니다.<br>
                    🔐 <strong>Jwt 필요 (role=ADMIN)</strong><br>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 유저 상세 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = AdminUserDetailResponse.class),
                            examples = @ExampleObject(
                                    name = "성공 예시",
                                    value = """
                                            {
                                              "userId": 1001,
                                              "email": "user@example.com",
                                              "nickname": "홍길동",
                                              "handle": "gildong",
                                              "profileImgNumber": 3,
                                              "role": "USER",
                                              "status": "ACTIVE",
                                              "level": 12,
                                              "createdAt": "2026-01-15"
                                            }
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 유저를 찾을 수 없음",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "유저 없음",
                                    value = "{\"error\" : \"USER_4041\", \"message\" : \"존재하지 않는 유저입니다.\"}"
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "예기치 못한 예외 발생",
                                    value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping("/{userId}")
    ResponseEntity<AdminUserDetailResponse> getUserDetail(
            @Parameter(description = "유저 ID") @PathVariable("userId") long userId
    );

    @Operation(
            summary = "유저 상태 변경",
            description = """
                    특정 유저의 상태를 변경합니다.<br>
                    - ACTIVE: 정지 해제 (SUSPENDED → ACTIVE)<br>
                    - SUSPENDED: 이용 정지 (ACTIVE → SUSPENDED)<br>
                    ⚠️ DELETED 전환은 이 API에서 불허 (400 반환)<br>
                    ⚠️ 삭제된 유저(소프트 딜리트)는 조회 불가 → 404 반환<br>
                    🔐 <strong>Jwt 필요 (role=ADMIN)</strong><br>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 유저 상태 변경 성공"
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "🚨 허용되지 않는 상태 전환 또는 잘못된 status 값",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = {
                                    @ExampleObject(
                                            name = "DELETED 전환 시도",
                                            value = "{\"error\" : \"ADMIN_4001\", \"message\" : \"해당 유저 상태로 변경할 수 없습니다.\"}"
                                    ),
                                    @ExampleObject(
                                            name = "존재하지 않는 status 값",
                                            value = "{\"error\" : \"GLOBAL_4001\", \"message\" : \"잘못된 요청입니다.\"}"
                                    )
                            }
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 유저를 찾을 수 없음",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "유저 없음",
                                    value = "{\"error\" : \"USER_4041\", \"message\" : \"존재하지 않는 유저입니다.\"}"
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "예기치 못한 예외 발생",
                                    value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @PatchMapping("/{userId}/status")
    ResponseEntity<Void> updateUserStatus(
            @Parameter(description = "유저 ID") @PathVariable("userId") long userId,
            @Valid @RequestBody AdminUserStatusUpdateRequest request
    );
}
