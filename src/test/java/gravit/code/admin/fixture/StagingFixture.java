package gravit.code.admin.fixture;

import gravit.code.admin.domain.staging.AnswerStaging;
import gravit.code.admin.domain.staging.LessonStaging;
import gravit.code.admin.domain.staging.OptionStaging;
import gravit.code.admin.domain.staging.ProblemStaging;
import gravit.code.admin.domain.staging.StagingLabel;
import gravit.code.problem.domain.ProblemType;

/**
 * staging 엔티티 테스트 픽스처. PK 는 앱 발번(IDENTITY 아님)이라 id 를 직접 지정해 저장한다.
 */
public class StagingFixture {

    public static StagingLabel 라벨(
            Long id,
            String label,
            long unitId
    ) {
        return StagingLabel.create(id, label, unitId, "설명-" + label);
    }

    public static LessonStaging 레슨(
            Long id,
            long unitId,
            String label
    ) {
        return LessonStaging.create(id, unitId, "스테이징 레슨 " + id, label);
    }

    public static ProblemStaging 문제(
            Long id,
            long lessonId,
            ProblemType type,
            String label
    ) {
        return ProblemStaging.create(id, lessonId, "내용 " + id, "지시문 " + id, type, label);
    }

    public static OptionStaging 옵션(
            Long id,
            long problemId,
            boolean isAnswer,
            String label
    ) {
        return OptionStaging.create(id, problemId, "옵션 " + id, "해설 " + id, isAnswer, label);
    }

    public static AnswerStaging 정답(
            Long id,
            Long problemId,
            String label
    ) {
        return AnswerStaging.create(id, problemId, "정답 " + id, "정답해설 " + id, label);
    }
}
