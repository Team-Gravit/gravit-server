package gravit.code.interview.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.interview.domain.InterviewStackGroup;
import gravit.code.interview.dto.response.InterviewStackGroupResponse;
import gravit.code.interview.dto.response.InterviewStackResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@Tag(name = "Interview Stack Group API", description = "AI 면접 직군 그룹과 스택 선택지 조회 API")
public interface InterviewStackGroupControllerDocs {

    @Operation(
            summary = "직군 그룹 목록 조회",
            description = """
                    직군(JOB_SPECIFIC) 모드에서 고를 수 있는 직군 그룹을 노출 순서대로 반환합니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 직군 그룹 목록 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "직군 그룹 목록 예시",
                                    value = """
                                            [
                                              { "stackGroup": "SERVER", "displayName": "Server" },
                                              { "stackGroup": "WEB", "displayName": "Web" },
                                              { "stackGroup": "AOS", "displayName": "AOS" },
                                              { "stackGroup": "IOS", "displayName": "iOS" }
                                            ]
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 서버 내부 오류",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"서버 내부 오류가 발생했습니다.\"}"
                            )
                    )
            )
    })
    ResponseEntity<List<InterviewStackGroupResponse>> getStackGroups(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(
            summary = "직군 그룹별 스택 목록 조회",
            description = """
                    해당 직군 그룹에 속한 스택을 노출 순서대로 반환합니다.<br>
                    직군 모드는 이 목록에서 스택 하나를 골라 세션을 만듭니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 스택 목록 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "SERVER 그룹 스택 목록 예시",
                                    value = """
                                            [
                                              { "stack": "JAVA_SPRING_BOOT", "displayName": "Java + Spring Boot" },
                                              { "stack": "KOTLIN_SPRING_BOOT", "displayName": "Kotlin + Spring Boot" },
                                              { "stack": "NODE_NEST", "displayName": "Node.js + NestJS" },
                                              { "stack": "PYTHON_DJANGO", "displayName": "Python + Django" }
                                            ]
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 서버 내부 오류",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"서버 내부 오류가 발생했습니다.\"}"
                            )
                    )
            )
    })
    ResponseEntity<List<InterviewStackResponse>> getStacks(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "직군 그룹", example = "SERVER") @PathVariable InterviewStackGroup stackGroup
    );
}
