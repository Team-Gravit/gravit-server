package gravit.code.interviewFeedback.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.interview.domain.InterviewSessionSort;
import gravit.code.interview.dto.response.InterviewSessionHistoryResponse;
import gravit.code.interview.dto.response.InterviewSessionHistorySliceResponse;
import gravit.code.interviewFeedback.dto.response.InterviewDashboardResponse;
import gravit.code.interviewFeedback.dto.response.InterviewSessionAnswersResponse;
import gravit.code.interviewFeedback.dto.response.InterviewSessionSummaryResponse;
import gravit.code.interviewFeedback.dto.response.InterviewTopicAccuracyResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Tag(name = "Interview Feedback API", description = "AI 면접 결과 조회 API (응시 이력, 세션 종합, 문항별 상세, 메인 화면, 약점 주제)")
public interface InterviewFeedbackControllerDocs {

    @Operation(
            summary = "면접 응시 이력 조회",
            description = """
                    완료(COMPLETED)된 면접 세션 목록을 페이지당 10건씩 조회합니다.<br>
                    sort=LATEST(기본)는 최신순, OLDEST는 오래된 순이며 정렬 기준은 세션 시작 시각입니다.<br>
                    stack은 직군 모드에서만 값이 있고 공통 CS 모드는 null입니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 응시 이력 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewSessionHistorySliceResponse.class),
                            examples = @ExampleObject(
                                    name = "응시 이력 조회 성공 예시",
                                    value = """
                                            {
                                              "hasNextPage": false,
                                              "contents": [
                                                {
                                                  "sessionId": 12,
                                                  "sequence": 3,
                                                  "mode": "COMMON_CS",
                                                  "stack": null,
                                                  "topics": [
                                                    {"topic": "DATA_STRUCTURE", "displayName": "자료구조"},
                                                    {"topic": "NETWORK", "displayName": "네트워크"}
                                                  ],
                                                  "startedAt": "2026-09-04T10:15:30",
                                                  "score": 78,
                                                  "maxScore": 100
                                                },
                                                {
                                                  "sessionId": 9,
                                                  "sequence": 2,
                                                  "mode": "JOB_SPECIFIC",
                                                  "stack": {"stack": "JAVA_SPRING_BOOT", "displayName": "Java + Spring Boot"},
                                                  "topics": [
                                                    {"topic": "SERVER_COMMON", "displayName": "서버 공통"},
                                                    {"topic": "JAVA", "displayName": "Java"},
                                                    {"topic": "SPRING_BOOT", "displayName": "Spring Boot"}
                                                  ],
                                                  "startedAt": "2026-09-02T21:03:11",
                                                  "score": 65,
                                                  "maxScore": 100
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
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping
    ResponseEntity<SliceResponse<InterviewSessionHistoryResponse>> getSessionHistory(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "0부터 시작하는 페이지 인덱스", example = "0")
            @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "정렬 (LATEST: 최신순, OLDEST: 오래된 순)", example = "LATEST")
            @RequestParam(defaultValue = "LATEST") InterviewSessionSort sort
    );

    @Operation(
            summary = "면접 세션 종합 조회",
            description = """
                    완료된 세션의 리포트 종합을 조회합니다.<br>
                    총점과 만점, 정확도와 전달력, 전체 사용자 평균, 이 세션을 포함한 최근 완료 세션 5개의 추이(오래된 순), 문항별 점수, 약점 분야를 담습니다.<br>
                    약점 분야는 문항 획득 점수가 문항 만점의 절반 이하인 문항의 유닛이며 중복을 제거합니다.<br>
                    본인 세션이 아니면 403, 완료되지 않은 세션이면 409입니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 세션 종합 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewSessionSummaryResponse.class),
                            examples = @ExampleObject(
                                    name = "세션 종합 조회 성공 예시",
                                    value = """
                                            {
                                              "sessionId": 12,
                                              "sequence": 3,
                                              "startedAt": "2026-09-04T10:15:30",
                                              "score": 78,
                                              "maxScore": 100,
                                              "accuracyScore": 54,
                                              "accuracyMaxScore": 70,
                                              "deliveryScore": 24,
                                              "deliveryMaxScore": 30,
                                              "averageAccuracyScore": 49,
                                              "averageDeliveryScore": 21,
                                              "recentSessions": [
                                                {"sessionId": 5, "sequence": 1, "accuracyScore": 40, "deliveryScore": 18},
                                                {"sessionId": 9, "sequence": 2, "accuracyScore": 47, "deliveryScore": 18},
                                                {"sessionId": 12, "sequence": 3, "accuracyScore": 54, "deliveryScore": 24}
                                              ],
                                              "answers": [
                                                {"displayOrder": 1, "topic": {"topic": "DATA_STRUCTURE", "displayName": "자료구조"}, "accuracyScore": 12, "deliveryScore": 5},
                                                {"displayOrder": 2, "topic": {"topic": "NETWORK", "displayName": "네트워크"}, "accuracyScore": 4, "deliveryScore": 3}
                                              ],
                                              "weakTopics": [
                                                {"unitId": 7, "topic": {"topic": "NETWORK", "displayName": "네트워크"}}
                                              ]
                                            }
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "🚨 본인의 세션이 아님",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "세션 접근 거부",
                                    value = "{\"error\": \"INTERVIEW_4004\", \"message\": \"본인의 면접 세션만 접근할 수 있습니다.\"}"
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 세션 없음",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "세션 없음",
                                    value = "{\"error\": \"INTERVIEW_4003\", \"message\": \"존재하지 않는 면접 세션입니다.\"}"
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "409",
                    description = "🚨 완료되지 않은 세션 (진행 중, 채점 중, 채점 실패, 취소)",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "채점 미완료",
                                    value = "{\"error\": \"INTERVIEW_4012\", \"message\": \"면접 채점이 완료되지 않아 피드백을 조회할 수 없습니다.\"}"
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
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping("/{sessionId}/summary")
    ResponseEntity<InterviewSessionSummaryResponse> getSessionSummary(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "면접 세션 ID", example = "12")
            @PathVariable long sessionId
    );

    @Operation(
            summary = "면접 문항별 상세 조회",
            description = """
                    완료된 세션의 5문항 상세를 문항 순서대로 조회합니다.<br>
                    질문, 주제, 사용자 답변(음성 세션은 음성 키 포함), 모범답안, 핵심 개념 목록, 점수 분해(정확도 14, 구조성 3, 명료성 3), 개선 제안을 담습니다.<br>
                    핵심 개념 목록에는 개념별 전달 여부가 없습니다. 무응답 문항은 answerContent와 improvementSuggestion이 null이고 세 점수가 0입니다.<br>
                    본인 세션이 아니면 403, 완료되지 않은 세션이면 409입니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 문항별 상세 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewSessionAnswersResponse.class),
                            examples = @ExampleObject(
                                    name = "문항별 상세 조회 성공 예시",
                                    value = """
                                            {
                                              "sessionId": 12,
                                              "answers": [
                                                {
                                                  "displayOrder": 1,
                                                  "topic": {"topic": "ALGORITHM", "displayName": "알고리즘"},
                                                  "questionContent": "퀵 정렬의 동작 방식과 시간복잡도를 설명해주세요.",
                                                  "answerContent": "피벗을 기준으로 분할하며 정렬합니다. 평균 O(n log n)입니다.",
                                                  "audioKey": null,
                                                  "modelAnswer": "퀵 정렬은 피벗을 기준으로 작은 값과 큰 값을 나누며 재귀적으로 정렬합니다. 평균 O(n log n), 최악 O(n^2)입니다.",
                                                  "concepts": [
                                                    {"name": "피벗 기준 분할을 설명", "type": "ESSENTIAL"},
                                                    {"name": "평균 시간복잡도가 O(n log n)임을 언급", "type": "ESSENTIAL"},
                                                    {"name": "최악의 경우 O(n^2)가 되는 조건을 언급", "type": "SUPPLEMENTARY"}
                                                  ],
                                                  "improvementSuggestion": "최악의 경우 O(n^2)가 되는 조건을 함께 언급하면 좋습니다.",
                                                  "accuracyScore": 11,
                                                  "accuracyMaxScore": 14,
                                                  "structureScore": 3,
                                                  "structureMaxScore": 3,
                                                  "clarityScore": 2,
                                                  "clarityMaxScore": 3
                                                },
                                                {
                                                  "displayOrder": 2,
                                                  "topic": {"topic": "NETWORK", "displayName": "네트워크"},
                                                  "questionContent": "TCP 3-way handshake 과정을 설명해주세요.",
                                                  "answerContent": null,
                                                  "audioKey": null,
                                                  "modelAnswer": "SYN, SYN-ACK, ACK 세 단계로 연결을 수립합니다.",
                                                  "concepts": [
                                                    {"name": "SYN, SYN-ACK, ACK 순서를 설명", "type": "ESSENTIAL"}
                                                  ],
                                                  "improvementSuggestion": null,
                                                  "accuracyScore": 0,
                                                  "accuracyMaxScore": 14,
                                                  "structureScore": 0,
                                                  "structureMaxScore": 3,
                                                  "clarityScore": 0,
                                                  "clarityMaxScore": 3
                                                }
                                              ]
                                            }
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "🚨 본인의 세션이 아님",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "세션 접근 거부",
                                    value = "{\"error\": \"INTERVIEW_4004\", \"message\": \"본인의 면접 세션만 접근할 수 있습니다.\"}"
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 세션 없음",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "세션 없음",
                                    value = "{\"error\": \"INTERVIEW_4003\", \"message\": \"존재하지 않는 면접 세션입니다.\"}"
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "409",
                    description = "🚨 완료되지 않은 세션 (진행 중, 채점 중, 채점 실패, 취소)",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "채점 미완료",
                                    value = "{\"error\": \"INTERVIEW_4012\", \"message\": \"면접 채점이 완료되지 않아 피드백을 조회할 수 없습니다.\"}"
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
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping("/{sessionId}/answers")
    ResponseEntity<InterviewSessionAnswersResponse> getSessionAnswers(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "면접 세션 ID", example = "12")
            @PathVariable long sessionId
    );

    @Operation(
            summary = "면접 메인 화면 조회",
            description = """
                    면접 메인 화면에 필요한 값을 한 번에 조회합니다. 모두 완료(COMPLETED) 세션 기준입니다.<br>
                    completedSessionCount: 완료 세션 수<br>
                    recentAverageScore: 최근 완료 세션 5개의 총점 평균, 반올림 정수 (완료 세션이 없으면 0)<br>
                    weakestTopics: 주제별 정확도율 오름차순 하위 3개<br>
                    recentSessions: 최근 완료 세션 3개 (최신순)<br>
                    scoreTrends: 최근 완료 세션 5개의 점수 추이 (오래된 순)<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 메인 화면 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = InterviewDashboardResponse.class),
                            examples = @ExampleObject(
                                    name = "메인 화면 조회 성공 예시",
                                    value = """
                                            {
                                              "completedSessionCount": 7,
                                              "recentAverageScore": 71,
                                              "weakestTopics": [
                                                {"topic": {"topic": "NETWORK", "displayName": "네트워크"}, "accuracyRate": 42.9},
                                                {"topic": {"topic": "OPERATING_SYSTEM", "displayName": "운영체제"}, "accuracyRate": 57.1},
                                                {"topic": {"topic": "DATABASE", "displayName": "데이터베이스"}, "accuracyRate": 64.3}
                                              ],
                                              "recentSessions": [
                                                {
                                                  "sessionId": 12,
                                                  "sequence": 7,
                                                  "mode": "COMMON_CS",
                                                  "stack": null,
                                                  "topics": [{"topic": "NETWORK", "displayName": "네트워크"}],
                                                  "startedAt": "2026-09-04T10:15:30",
                                                  "score": 78,
                                                  "maxScore": 100
                                                }
                                              ],
                                              "scoreTrends": [
                                                {"sequence": 3, "score": 65},
                                                {"sequence": 4, "score": 70},
                                                {"sequence": 5, "score": 68},
                                                {"sequence": 6, "score": 76},
                                                {"sequence": 7, "score": 78}
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
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping("/dashboard")
    ResponseEntity<InterviewDashboardResponse> getDashboard(
            @AuthenticationPrincipal LoginUser loginUser
    );

    @Operation(
            summary = "면접 약점 주제 전체 조회",
            description = """
                    완료 세션의 문항을 주제별로 모아 계산한 정확도율(0~100)을 오름차순으로 전부 조회합니다.<br>
                    정확도율 = 주제별 문항 정확도 점수 합 / 문항 정확도 만점 합 x 100 (무응답 문항은 0점으로 포함, 소수점 첫째 자리).<br>
                    완료 세션이 없으면 빈 배열입니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 약점 주제 전체 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            array = @ArraySchema(schema = @Schema(implementation = InterviewTopicAccuracyResponse.class)),
                            examples = @ExampleObject(
                                    name = "약점 주제 전체 조회 성공 예시",
                                    value = """
                                            [
                                              {"topic": {"topic": "NETWORK", "displayName": "네트워크"}, "accuracyRate": 42.9},
                                              {"topic": {"topic": "OPERATING_SYSTEM", "displayName": "운영체제"}, "accuracyRate": 57.1},
                                              {"topic": {"topic": "DATABASE", "displayName": "데이터베이스"}, "accuracyRate": 64.3},
                                              {"topic": {"topic": "ALGORITHM", "displayName": "알고리즘"}, "accuracyRate": 78.6},
                                              {"topic": {"topic": "DATA_STRUCTURE", "displayName": "자료구조"}, "accuracyRate": 85.7}
                                            ]
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
                                    name = "서버 오류",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping("/weak-topics")
    ResponseEntity<List<InterviewTopicAccuracyResponse>> getWeakTopics(
            @AuthenticationPrincipal LoginUser loginUser
    );
}
