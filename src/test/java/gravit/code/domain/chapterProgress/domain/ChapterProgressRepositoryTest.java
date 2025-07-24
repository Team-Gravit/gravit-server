package gravit.code.domain.chapterProgress.domain;

import gravit.code.domain.chapter.domain.Chapter;
import gravit.code.domain.chapter.domain.ChapterRepository;
import gravit.code.domain.chapterProgress.dto.response.ChapterInfoResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class ChapterProgressRepositoryTest {

    @Autowired
    private ChapterProgressRepository chapterProgressRepository;

    @Autowired
    private ChapterRepository chapterRepository;

    @BeforeEach
    void setUp() {
        ChapterProgress chapterProgress = ChapterProgress.create(
            10L, 1L,1L
        );
        chapterProgressRepository.save(chapterProgress);

        Chapter chapter1 = Chapter.create(
                "자료구조", "큐, 스택, 힙과 같은 자료구조에 대해 학습합니다.", 10L
        );
        chapterRepository.save(chapter1);

        Chapter chapter2 = Chapter.create(
                "컴퓨터 네트워크", "컴퓨터 네트워크와 관련된 개념을 학습합니다.", 11L
        );
        chapterRepository.save(chapter2);

        Chapter chapter3 = Chapter.create(
                "자료구조", "큐, 스택, 힙과 같은 자료구조에 대해 학습합니다.", 12L
        );
        chapterRepository.save(chapter3);

        Chapter chapter4 = Chapter.create(
                "자료구조", "큐, 스택, 힙과 같은 자료구조에 대해 학습합니다.", 13L
        );
        chapterRepository.save(chapter4);

        ChapterProgress chapterProgress1 = ChapterProgress.create(
                10L, 2L, chapter1.getId()
        );
        chapterProgressRepository.save(chapterProgress1);

        ChapterProgress chapterProgress2 = ChapterProgress.create(
                11L, 2L, chapter2.getId()
        );
        chapterProgressRepository.save(chapterProgress2);

        ChapterProgress chapterProgress3 = ChapterProgress.create(
                12L, 2L, chapter3.getId()
        );
        chapterProgressRepository.save(chapterProgress3);
    }

    @Test
    @DisplayName("유효한 chapterId와 userId로 ChapterProgress를 조회할 수 있다.")
    void getChapterProgressByValidChapterIdAndUserId() {
        //given
        Long chapterId = 1L;
        Long userId = 1L;

        //when

        Optional<ChapterProgress> chapterProgress = chapterProgressRepository.findByChapterIdAndUserId(chapterId, userId);
        //then
        assertThat(chapterProgress).isPresent();
        assertThat(chapterProgress.get().getChapterId()).isEqualTo(chapterId);
        assertThat(chapterProgress.get().getUserId()).isEqualTo(userId);
    }

    @Test
    @DisplayName("유효하지 않은 chapterId와 userId로 ChapterProgress를 조회하면 Optional.empty()를 반환한다.")
    void getChapterProgressByInvalidChapterIdAndUserId() {
        //given
        Long chapterId = 22222L;
        Long userId = 22222L;

        //when
        Optional<ChapterProgress> chapterProgress = chapterProgressRepository.findByChapterIdAndUserId(chapterId, userId);

        //then
        assertThat(chapterProgress).isNotPresent();
    }

    @Test
    @DisplayName("chapterId와 userId로 조회하는 경우 ChapterProgress가 존재한다면 true를 반환한다.")
    void getTrueWhenChapterProgressExistsWithChapterIdAndUserId() {
        //given
        Long chapterId = 1L;
        Long userId = 2L;

        //when
        boolean exists = chapterProgressRepository.existsByChapterIdAndUserId(chapterId, userId);

        //then
        assertThat(exists).isTrue();
    }

    @Test
    @DisplayName("chapterId와 userId로 조회하는 경우 ChapterProgress가 존재하지 않는다면 false를 반환한다.")
    void getFalseWhenChapterProgressNotExistsWithChapterIdAndUserId() {
        //given
        Long chapterId = 33L;
        Long userId = 33L;

        //when
        boolean exists = chapterProgressRepository.existsByChapterIdAndUserId(chapterId, userId);

        //then
        assertThat(exists).isFalse();
    }

    @Test
    @DisplayName("userId를 통해 ChapterInfoResponse를 조회할 수 있다.")
    void getChapterInfoResponsesByUserId(){
        //given
        Long userId = 2L;

        //when
        List<ChapterInfoResponse> chapterInfoResponses = chapterProgressRepository.findAllChaptersWithProgress(userId);

        assertThat(chapterInfoResponses).hasSize(4);
        assertThat(chapterInfoResponses.get(3).completedUnits()).isZero(); // SQL coalesce 함수 검증
    }
}