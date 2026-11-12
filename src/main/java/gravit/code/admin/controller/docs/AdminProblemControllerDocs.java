package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.ObjectiveProblemUpdateRequest;
import gravit.code.admin.dto.request.SubjectiveProblemUpdateRequest;
import gravit.code.admin.dto.response.ProblemDetailResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin Problem API", description = "백오피스 문제 관리 (객관/주관 분리 PATCH)")
public interface AdminProblemControllerDocs {

    @Operation(summary = "문제 상세", description = "OBJECTIVE=options(4) / SUBJECTIVE=answer(단일).")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "문제/옵션/정답 없음")
    })
    ResponseEntity<ProblemDetailResponse> getProblem(Long problemId);

    @Operation(summary = "객관식 문제 수정", description = "instruction/content 부분 수정, options 제공 시 4개 전체 교체(정답 1개).")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "수정 성공"),
            @ApiResponse(responseCode = "400", description = "옵션 4개/정답 1개 위반"),
            @ApiResponse(responseCode = "404", description = "문제/옵션 없음")
    })
    ResponseEntity<Void> updateObjective(
            Long problemId,
            ObjectiveProblemUpdateRequest request
    );

    @Operation(summary = "주관식 문제 수정", description = "instruction/content 부분 수정, answer(콤마 단일) 수정.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "수정 성공"),
            @ApiResponse(responseCode = "404", description = "문제/정답 없음")
    })
    ResponseEntity<Void> updateSubjective(
            Long problemId,
            SubjectiveProblemUpdateRequest request
    );
}
