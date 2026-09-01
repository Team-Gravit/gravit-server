package gravit.code.interviewTechStack.fixture;

import gravit.code.interviewTechStack.domain.InterviewAxis;
import gravit.code.interviewTechStack.domain.InterviewJobRole;
import gravit.code.interviewTechStack.domain.InterviewStackAxis;
import gravit.code.interviewTechStack.domain.InterviewTechStack;

public class InterviewTechStackFixture {

    public static InterviewTechStack 기술스택(
            InterviewJobRole jobRole,
            String code,
            String displayName,
            int sortOrder
    ) {
        return InterviewTechStack.create(jobRole, code, displayName, sortOrder);
    }

    public static InterviewStackAxis 축_매핑(
            long techStackId,
            InterviewAxis axis,
            long categoryId
    ) {
        return InterviewStackAxis.create(techStackId, axis, categoryId);
    }
}
