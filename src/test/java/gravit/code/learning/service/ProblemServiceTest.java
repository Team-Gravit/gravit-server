package gravit.code.learning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.OptionRepository;
import gravit.code.learning.domain.Problem;
import gravit.code.learning.domain.ProblemRepository;
import gravit.code.learning.domain.ProblemType;
import gravit.code.learning.dto.response.OptionResponse;
import gravit.code.learning.dto.response.ProblemResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProblemServiceTest {

    @Mock
    private ProblemRepository problemRepository;

    @Mock
    private OptionRepository optionRepository;

    @InjectMocks
    private ProblemService problemService;

    @Nested
    @DisplayName("모든 문제를 조회할 떄,")
    class GetAllProblems {

        private final List<Problem> problems;
        {
            Problem problem1 = Problem.create(ProblemType.OBJECTIVE, "스택의 기본 동작 원리는?", "스택 자료구조에 대한 문제입니다.", "1", 1L);
            ReflectionTestUtils.setField(problem1, "id", 1L);
            
            Problem problem2 = Problem.create(ProblemType.OBJECTIVE, "큐의 특징으로 올바른 것은?", "큐 자료구조에 대한 문제입니다.", "2", 1L);
            ReflectionTestUtils.setField(problem2, "id", 2L);
            
            Problem problem3 = Problem.create(ProblemType.OBJECTIVE, "연결 리스트의 장점은?", "연결 리스트에 대한 문제입니다.", "3", 1L);
            ReflectionTestUtils.setField(problem3, "id", 3L);
            
            Problem problem4 = Problem.create(ProblemType.OBJECTIVE, "배열의 시간 복잡도는?", "배열 접근에 대한 문제입니다.", "1", 1L);
            ReflectionTestUtils.setField(problem4, "id", 4L);
            
            Problem problem5 = Problem.create(ProblemType.SUBJECTIVE, "스택을 구현하는 방법을 설명하시오.", "스택 구현에 대한 문제입니다.", "배열이나 연결리스트로 구현 가능", 1L);
            ReflectionTestUtils.setField(problem5, "id", 5L);
            
            Problem problem6 = Problem.create(ProblemType.SUBJECTIVE, "큐와 스택의 차이점을 설명하시오.", "자료구조 비교 문제입니다.", "큐는 FIFO, 스택은 LIFO", 1L);
            ReflectionTestUtils.setField(problem6, "id", 6L);
            
            Problem problem7 = Problem.create(ProblemType.SUBJECTIVE, "해시 테이블의 충돌 해결 방법을 설명하시오.", "해시 테이블에 대한 문제입니다.", "체이닝, 개방주소법 등", 1L);
            ReflectionTestUtils.setField(problem7, "id", 7L);
            
            Problem problem8 = Problem.create(ProblemType.SUBJECTIVE, "트리와 그래프의 차이점은?", "그래프 이론 문제입니다.", "트리는 사이클이 없는 연결 그래프", 1L);
            ReflectionTestUtils.setField(problem8, "id", 8L);
            
            Problem problem9 = Problem.create(ProblemType.SUBJECTIVE, "정렬 알고리즘의 종류를 설명하시오.", "정렬에 대한 문제입니다.", "버블정렬, 퀵정렬, 머지정렬 등", 1L);
            ReflectionTestUtils.setField(problem9, "id", 9L);
            
            Problem problem10 = Problem.create(ProblemType.SUBJECTIVE, "이진 탐색의 조건은?", "탐색 알고리즘 문제입니다.", "정렬된 배열에서만 사용 가능", 1L);
            ReflectionTestUtils.setField(problem10, "id", 10L);
            
            Problem problem11 = Problem.create(ProblemType.SUBJECTIVE, "동적 프로그래밍이란?", "알고리즘 기법 문제입니다.", "중복되는 부분 문제를 저장하여 해결", 1L);
            ReflectionTestUtils.setField(problem11, "id", 11L);
            
            Problem problem12 = Problem.create(ProblemType.SUBJECTIVE, "재귀 함수의 특징을 설명하시오.", "재귀에 대한 문제입니다.", "자기 자신을 호출하는 함수", 1L);
            ReflectionTestUtils.setField(problem12, "id", 12L);
            
            problems = List.of(problem1, problem2, problem3, problem4, problem5, problem6, problem7, problem8, problem9, problem10, problem11, problem12);
        }

        private final List<OptionResponse> options = List.of(
                OptionResponse.create(1L, 1L, "LIFO (Last In First Out)", "스택은 마지막에 들어간 데이터가 먼저 나오는 구조입니다.", true),
                OptionResponse.create(2L, 1L, "FIFO (First In First Out)", "이는 큐의 특징입니다.", false),
                OptionResponse.create(3L, 1L, "랜덤 접근 가능", "스택은 순차 접근만 가능합니다.", false),
                OptionResponse.create(4L, 1L, "정렬된 데이터 저장", "스택은 정렬과 무관합니다.", false),

                OptionResponse.create(5L, 2L, "FIFO (First In First Out)", "큐는 먼저 들어간 데이터가 먼저 나오는 구조입니다.", true),
                OptionResponse.create(6L, 2L, "LIFO (Last In First Out)", "이는 스택의 특징입니다.", false),
                OptionResponse.create(7L, 2L, "이진 탐색 가능", "큐는 탐색 자료구조가 아닙니다.", false),
                OptionResponse.create(8L, 2L, "인덱스 접근 가능", "큐는 양 끝에서만 접근 가능합니다.", false),

                OptionResponse.create(9L, 3L, "동적 크기 조절", "연결 리스트는 실행 시간에 크기를 조절할 수 있습니다.", true),
                OptionResponse.create(10L, 3L, "빠른 랜덤 접근", "배열의 장점입니다.", false),
                OptionResponse.create(11L, 3L, "메모리 연속성", "배열의 장점입니다.", false),
                OptionResponse.create(12L, 3L, "캐시 효율성", "배열의 장점입니다.", false),

                OptionResponse.create(13L, 4L, "O(1)", "배열은 인덱스로 상수 시간에 접근 가능합니다.", true),
                OptionResponse.create(14L, 4L, "O(log n)", "이진 탐색의 시간 복잡도입니다.", false),
                OptionResponse.create(15L, 4L, "O(n)", "선형 탐색의 시간 복잡도입니다.", false),
                OptionResponse.create(16L, 4L, "O(n log n)", "정렬 알고리즘의 평균 시간 복잡도입니다.", false)
        );

        @Test
        @DisplayName("유효한 데이터로 조회하면 조회에 성공한다.")
        void withValidData(){
            //given
            Long lessonId = 1L;

            when(problemRepository.findAllProblemByLessonId(lessonId)).thenReturn(problems);
            when(optionRepository.findAllByProblemIdInIds(any())).thenReturn(options);

            //when
            List<ProblemResponse> problemResponses = problemService.getAllProblemInLesson(lessonId);

            //then
            assertThat(problemResponses).hasSize(12);
            
            // 객관식 문제
            List<ProblemResponse> objectiveProblems = problemResponses.stream()
                    .filter(p -> p.problemType() == ProblemType.OBJECTIVE)
                    .toList();
            assertThat(objectiveProblems).hasSize(4);
            
            // 주관식 문제
            List<ProblemResponse> subjectiveProblems = problemResponses.stream()
                    .filter(p -> p.problemType() == ProblemType.SUBJECTIVE)
                    .toList();
            assertThat(subjectiveProblems).hasSize(8);
            
            // 객관식 문제들은 선지가 있어야 함
            objectiveProblems.forEach(problem -> {
                assertThat(problem.options()).isNotEmpty();
                assertThat(problem.options()).hasSize(4);
            });
            
            // 주관식 문제들은 선지가 비어있어야 함
            subjectiveProblems.forEach(problem -> {
                assertThat(problem.options()).isEmpty();
            });
        }

        @Test
        @DisplayName("조회된 Problem 리스트가 비어있다면 예외를 반환한다.")
        void throwExceptionIfProblemListIsEmpty(){
            //given
            Long lessonId = 999L;
            when(problemRepository.findAllProblemByLessonId(lessonId)).thenReturn(List.of());

            //when & then
            assertThatThrownBy(() -> problemService.getAllProblemInLesson(lessonId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.PROBLEM_NOT_FOUND);
        }

        @Test
        @DisplayName("객관식 문제에 대해 Option을 조회했을 때 리스트가 비어있다면 예외를 반환한다.")
        void throwExceptionIfOptionMapIsEmpty(){
            //given
            Long lessonId = 1L;
            when(problemRepository.findAllProblemByLessonId(lessonId)).thenReturn(problems);
            when(optionRepository.findAllByProblemIdInIds(List.of(1L, 2L, 3L, 4L))).thenReturn(List.of());

            //when & then
            assertThatThrownBy(() -> problemService.getAllProblemInLesson(lessonId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.OPTION_NOT_FOUND);
        }
    }
}