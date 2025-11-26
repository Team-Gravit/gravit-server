package gravit.code.problem.service;

import gravit.code.answer.domain.AnswerRepository;
import gravit.code.answer.dto.response.AnswerResponse;
import gravit.code.bookmark.service.BookmarkService;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.option.domain.OptionRepository;
import gravit.code.option.dto.response.OptionResponse;
import gravit.code.problem.domain.ProblemRepository;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetail;
import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.wrongAnsweredNote.service.WrongAnsweredNoteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProblemService {

    private final WrongAnsweredNoteService wrongAnsweredNoteService;
    private final BookmarkService bookmarkService;

    private final ProblemRepository problemRepository;
    private final AnswerRepository answerRepository;
    private final OptionRepository optionRepository;

    @Transactional(readOnly = true)
    public List<ProblemResponse> getAllProblemInLesson(
            long lessonId,
            long userId
    ){
        List<ProblemDetail> problemDetails = problemRepository.findAllProblemDetailByLessonIdAndUserId(lessonId, userId);

        return getAnswerOrOptionInProblems(problemDetails);
    }

    @Transactional(readOnly = true)
    public List<ProblemResponse> getBookmarkedProblemInUnit(
            long unitId,
            long userId
    ){
        List<ProblemDetail> problemDetails = bookmarkService.findBookmarkedProblemDetailByUnitIdAndUserId(unitId, userId);

        return getAnswerOrOptionInProblems(problemDetails);
    }

    @Transactional(readOnly = true)
    public List<ProblemResponse> getWrongAnsweredProblemsInUnit(
            long unitId,
            long userId
    ) {
        List<ProblemDetail> problemDetails = wrongAnsweredNoteService.findWrongAnsweredProblemDetailByUnitIdAndUserId(unitId, userId);

        return getAnswerOrOptionInProblems(problemDetails);
    }

    private List<ProblemResponse> getAnswerOrOptionInProblems(List<ProblemDetail> problemDetails){
        return problemDetails.stream()
                .map(problem -> {
                    if (problem.problemType() == ProblemType.SUBJECTIVE){
                        AnswerResponse answerResponse = answerRepository.findByProblemId(problem.id())
                                .orElseThrow(() -> new RestApiException(CustomErrorCode.ANSWER_NOT_FOUND));

                        return ProblemResponse.createSubjectiveProblem(problem, answerResponse);
                    }else{
                        List<OptionResponse> optionResponses = optionRepository.findByProblemId(problem.id());

                        if(optionResponses.isEmpty())
                            throw new RestApiException(CustomErrorCode.OPTION_NOT_FOUND);

                        return ProblemResponse.createObjectiveProblem(problem, optionResponses);
                    }
                }).toList();
    }
}
