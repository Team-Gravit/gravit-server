package gravit.code.domain.chapterProgress.domain;

import gravit.code.domain.chapter.domain.Chapter;
import gravit.code.domain.chapter.infrastructure.ChapterJpaRepository;
import gravit.code.domain.chapterProgress.dto.response.ChapterInfoResponse;
import gravit.code.domain.chapterProgress.infrastructure.ChapterProgressJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.annotation.DirtiesContext;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
class ChapterProgressRepositoryTest {

    @Autowired
    private ChapterProgressJpaRepository chapterProgressJpaRepository;

    @Autowired
    private ChapterJpaRepository chapterJpaRepository;

    @BeforeEach
    void setUp() {
        Chapter chapter1 = Chapter.create(
                "자료구조0", "큐, 스택, 힙과 같은 자료구조에 대해 학습합니다.", 10L
        );
        chapterJpaRepository.save(chapter1);

        Chapter chapter2 = Chapter.create(
                "컴퓨터 네트워크", "컴퓨터 네트워크와 관련된 개념을 학습합니다.", 11L
        );
        chapterJpaRepository.save(chapter2);

        Chapter chapter3 = Chapter.create(
                "자료구조1", "큐, 스택, 힙과 같은 자료구조에 대해 학습합니다.", 12L
        );
        chapterJpaRepository.save(chapter3);

        Chapter chapter4 = Chapter.create(
                "자료구조2", "큐, 스택, 힙과 같은 자료구조에 대해 학습합니다.", 13L
        );
        chapterJpaRepository.save(chapter4);

        ChapterProgress chapterProgress1 = ChapterProgress.create(
                10L, 2L, chapter1.getId()
        );
        chapterProgressJpaRepository.save(chapterProgress1);

        ChapterProgress chapterProgress2 = ChapterProgress.create(
                11L, 2L, chapter2.getId()
        );
        chapterProgressJpaRepository.save(chapterProgress2);

        ChapterProgress chapterProgress3 = ChapterProgress.create(
                12L, 2L, chapter3.getId()
        );
        chapterProgressJpaRepository.save(chapterProgress3);
    }

    @Test
    @DisplayName("유효한 chapterId와 userId로 ChapterProgress를 조회할 수 있다.")
    void getChapterProgressByValidChapterIdAndUserId() {
        //given
        Long chapterId = 1L;
        Long userId = 2L;

        //when
        Optional<ChapterProgress> chapterProgress = chapterProgressJpaRepository.findByChapterIdAndUserId(chapterId, userId);

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
        Optional<ChapterProgress> chapterProgress = chapterProgressJpaRepository.findByChapterIdAndUserId(chapterId, userId);

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
        boolean exists = chapterProgressJpaRepository.existsByChapterIdAndUserId(chapterId, userId);

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
        boolean exists = chapterProgressJpaRepository.existsByChapterIdAndUserId(chapterId, userId);

        //then
        assertThat(exists).isFalse();
    }

    @Test
    @DisplayName("userId를 통해 ChapterInfoResponse를 조회할 수 있다.")
    void getChapterInfoResponsesByUserId(){
        //given
        Long userId = 2L;

        //when
        List<ChapterInfoResponse> chapterInfoResponses = chapterProgressJpaRepository.findAllChapterInfoByUserId(userId);

        assertThat(chapterInfoResponses).hasSize(4);
        assertThat(chapterInfoResponses.get(3).completedUnits()).isZero(); // SQL coalesce 함수 검증
    }
}