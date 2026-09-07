package gravit.code.interviewQuestion.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.interviewQuestion.dto.response.InterviewTopicResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import java.util.List;

@Tag(name = "Interview Topic API", description = "AI 면접 주제 선택지 조회 API")
public interface InterviewTopicControllerDocs {

    @Operation(
            summary = "공통 CS 주제 목록 조회",
            description = """
                    공통 CS(COMMON_CS) 모드에서 고를 수 있는 주제를 선언 순서대로 반환합니다.<br>
                    직군 모드의 주제는 스택을 통해 정해지므로 이 목록에 포함되지 않습니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 주제 목록 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = @ExampleObject(
                                    name = "주제 목록 예시",
                                    value = """
                                            [
                                              { "topic": "DATA_STRUCTURE", "displayName": "자료구조" },
                                              { "topic": "ALGORITHM", "displayName": "알고리즘" },
                                              { "topic": "DATABASE", "displayName": "데이터베이스" },
                                              { "topic": "OPERATING_SYSTEM", "displayName": "운영체제" },
                                              { "topic": "NETWORK", "displayName": "네트워크" }
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
    ResponseEntity<List<InterviewTopicResponse>> getCsTopics(@AuthenticationPrincipal LoginUser loginUser);
}
