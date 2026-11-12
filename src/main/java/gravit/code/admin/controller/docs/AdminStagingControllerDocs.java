package gravit.code.admin.controller.docs;

import gravit.code.admin.domain.staging.LabelStatus;
import gravit.code.admin.dto.request.LabelStatusUpdateRequest;
import gravit.code.admin.dto.request.StagingAnswerUpdateRequest;
import gravit.code.admin.dto.request.StagingLessonUpdateRequest;
import gravit.code.admin.dto.request.StagingOptionUpdateRequest;
import gravit.code.admin.dto.request.StagingProblemUpdateRequest;
import gravit.code.admin.dto.response.StagingLabelDetailResponse;
import gravit.code.admin.dto.response.StagingLabelListItemResponse;
import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.PageResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin Staging API", description = "백오피스 콘텐츠 검수/승급")
public interface AdminStagingControllerDocs {

    @Operation(summary = "스테이징 라벨 목록", description = "status(PENDING/COMPLETED) 필터.")
    @ApiResponses(@ApiResponse(responseCode = "200", description = "조회 성공"))
    ResponseEntity<PageResponse<StagingLabelListItemResponse>> getLabels(
            int page,
            LabelStatus status
    );

    @Operation(summary = "스테이징 라벨 상세", description = "lesson + problems(options|answer) 그루핑.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 라벨")
    })
    ResponseEntity<StagingLabelDetailResponse> getLabelDetail(String label);

    @Operation(summary = "스테이징 레슨 수정", description = "라벨이 COMPLETED 면 409.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "수정 성공"),
            @ApiResponse(responseCode = "404", description = "대상 없음"),
            @ApiResponse(responseCode = "409", description = "이미 승급 완료된 라벨")
    })
    ResponseEntity<Void> updateLesson(
            Long lessonId,
            StagingLessonUpdateRequest request
    );

    @Operation(summary = "스테이징 문제 수정 (부분)", description = "라벨이 COMPLETED 면 409.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "수정 성공"),
            @ApiResponse(responseCode = "404", description = "대상 없음"),
            @ApiResponse(responseCode = "409", description = "이미 승급 완료된 라벨")
    })
    ResponseEntity<Void> updateProblem(
            Long problemId,
            StagingProblemUpdateRequest request
    );

    @Operation(summary = "스테이징 옵션 수정 (부분)", description = "라벨이 COMPLETED 면 409.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "수정 성공"),
            @ApiResponse(responseCode = "404", description = "대상 없음"),
            @ApiResponse(responseCode = "409", description = "이미 승급 완료된 라벨")
    })
    ResponseEntity<Void> updateOption(
            Long optionId,
            StagingOptionUpdateRequest request
    );

    @Operation(summary = "스테이징 정답 수정 (부분)", description = "라벨이 COMPLETED 면 409.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "수정 성공"),
            @ApiResponse(responseCode = "404", description = "대상 없음"),
            @ApiResponse(responseCode = "409", description = "이미 승급 완료된 라벨")
    })
    ResponseEntity<Void> updateAnswer(
            Long answerId,
            StagingAnswerUpdateRequest request
    );

    @Operation(summary = "스테이징 라벨 승급(promote)", description = "status=COMPLETED 로 staging->prod 전환. 비가역. 감사 로그 기록.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "승급 성공"),
            @ApiResponse(responseCode = "400", description = "status 값 오류/불변식 위반"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 라벨"),
            @ApiResponse(responseCode = "409", description = "이미 승급 완료된 라벨")
    })
    ResponseEntity<Void> promote(
            LoginUser loginUser,
            String label,
            LabelStatusUpdateRequest request
    );
}
