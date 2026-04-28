package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.response.UserDetailResponse;
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
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Admin User API", description = "백오피스 유저 관리 관련 API")
public interface AdminUserControllerDocs {

    @Operation(
            summary = "유저 목록 조회",
            description = """
                    백오피스 유저 관리 화면의 유저 목록을 페이지 단위로 조회합니다.<br>
                    - page: 1-based 페이지 번호 (기본값 1, 페이지당 10건, id DESC 정렬)<br>
                    - search: email/nickname/handle 부분 일치 검색 (대소문자 구분)<br>
                    - status: ACTIVE | DELETED (미지정 시 전체)<br>
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
    ResponseEntity<PageResponse<UserDetailResponse>> getUsers(
            @Parameter(description = "페이지 번호 (1-based, 기본값 1)") @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "email/nickname/handle 검색 키워드") @RequestParam(required = false) String search,
            @Parameter(description = "유저 상태 (ACTIVE | DELETED)") @RequestParam(required = false) UserStatus status,
            @Parameter(description = "유저 권한 (ADMIN | USER)") @RequestParam(required = false) Role role
    );
}
