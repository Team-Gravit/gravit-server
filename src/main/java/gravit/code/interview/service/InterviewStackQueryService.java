package gravit.code.interview.service;

import gravit.code.interview.domain.InterviewStack;
import gravit.code.interview.domain.InterviewStackGroup;
import gravit.code.interview.dto.response.InterviewStackGroupResponse;
import gravit.code.interview.dto.response.InterviewStackResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InterviewStackQueryService {

    public List<InterviewStackGroupResponse> getStackGroups() {
        return Arrays.stream(InterviewStackGroup.values())
                .sorted(Comparator.comparingInt(InterviewStackGroup::getDisplayOrder))
                .map(InterviewStackGroupResponse::from)
                .toList();
    }

    public List<InterviewStackResponse> getStacks(InterviewStackGroup stackGroup) {
        return Arrays.stream(InterviewStack.values())
                .filter(stack -> stack.getGroup() == stackGroup)
                .sorted(Comparator.comparingInt(InterviewStack::getDisplayOrder))
                .map(InterviewStackResponse::from)
                .toList();
    }
}
