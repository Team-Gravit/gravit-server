package gravit.code.notice.service;

import gravit.code.notice.domain.Notice;
import gravit.code.notice.dto.response.NoticeDetailResponse;
import gravit.code.notice.fixture.NoticeFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDateTime;

import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class NoticeQueryServiceIntegrationTest {

    private static final LocalDateTime BASE_PUBLISHED_AT = LocalDateTime.of(2025, 8, 1, 10, 0);

    @Autowired
    private NoticeQueryService noticeQueryService;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private NoticeFixture noticeFixture;

    private User author;

    @BeforeEach
    void setUp() {
        author = userFixture.일반_유저(1);
    }

    @Nested
    @DisplayName("공지 상세의 이전, 다음 공지를 조회할 때")
    class GetNoticeDetailNeighbors {

        @Test
        void 중간_공지는_바로_더_최근_공지를_이전으로_바로_더_오래된_공지를_다음으로_준다() {
            // given
            noticeFixture.게시된_공지(author, "가장 오래된 공지", BASE_PUBLISHED_AT);
            Notice older = noticeFixture.게시된_공지(author, "오래된 공지", BASE_PUBLISHED_AT.plusDays(1));
            Notice middle = noticeFixture.게시된_공지(author, "중간 공지", BASE_PUBLISHED_AT.plusDays(2));
            Notice newer = noticeFixture.게시된_공지(author, "최근 공지", BASE_PUBLISHED_AT.plusDays(3));
            noticeFixture.게시된_공지(author, "가장 최근 공지", BASE_PUBLISHED_AT.plusDays(4));

            // when
            NoticeDetailResponse result = noticeQueryService.getNoticeDetail(middle.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.prev().id()).isEqualTo(newer.getId());
                softly.assertThat(result.prev().title()).isEqualTo("최근 공지");
                softly.assertThat(result.next().id()).isEqualTo(older.getId());
                softly.assertThat(result.next().title()).isEqualTo("오래된 공지");
            });
        }

        @Test
        void 가장_최근_공지는_이전_공지가_없다() {
            // given
            Notice older = noticeFixture.게시된_공지(author, "오래된 공지", BASE_PUBLISHED_AT);
            Notice newest = noticeFixture.게시된_공지(author, "가장 최근 공지", BASE_PUBLISHED_AT.plusDays(1));

            // when
            NoticeDetailResponse result = noticeQueryService.getNoticeDetail(newest.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.prev()).isNull();
                softly.assertThat(result.next().id()).isEqualTo(older.getId());
            });
        }

        @Test
        void 가장_오래된_공지는_다음_공지가_없다() {
            // given
            Notice oldest = noticeFixture.게시된_공지(author, "가장 오래된 공지", BASE_PUBLISHED_AT);
            Notice newer = noticeFixture.게시된_공지(author, "최근 공지", BASE_PUBLISHED_AT.plusDays(1));

            // when
            NoticeDetailResponse result = noticeQueryService.getNoticeDetail(oldest.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.prev().id()).isEqualTo(newer.getId());
                softly.assertThat(result.next()).isNull();
            });
        }

        @Test
        void 고정_공지_상세는_이전_다음_공지가_모두_없다() {
            // given
            noticeFixture.게시된_공지(author, "오래된 공지", BASE_PUBLISHED_AT);
            Notice pinned = noticeFixture.고정_공지(author, "고정 공지", BASE_PUBLISHED_AT.plusDays(1));
            noticeFixture.게시된_공지(author, "최근 공지", BASE_PUBLISHED_AT.plusDays(2));

            // when
            NoticeDetailResponse result = noticeQueryService.getNoticeDetail(pinned.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.pinned()).isTrue();
                softly.assertThat(result.prev()).isNull();
                softly.assertThat(result.next()).isNull();
            });
        }

        @Test
        void 고정_공지는_다른_공지의_이전_다음에서_빠진다() {
            // given
            Notice older = noticeFixture.게시된_공지(author, "오래된 공지", BASE_PUBLISHED_AT);
            noticeFixture.고정_공지(author, "고정 공지", BASE_PUBLISHED_AT.plusDays(1));
            Notice newer = noticeFixture.게시된_공지(author, "최근 공지", BASE_PUBLISHED_AT.plusDays(2));

            // when
            NoticeDetailResponse olderResult = noticeQueryService.getNoticeDetail(older.getId());
            NoticeDetailResponse newerResult = noticeQueryService.getNoticeDetail(newer.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(olderResult.prev().id()).isEqualTo(newer.getId());
                softly.assertThat(newerResult.next().id()).isEqualTo(older.getId());
            });
        }

        @Test
        void 임시_저장_보관_삭제된_공지는_이전_다음에서_빠진다() {
            // given
            Notice older = noticeFixture.게시된_공지(author, "오래된 공지", BASE_PUBLISHED_AT);
            noticeFixture.게시일이_있는_임시_저장_공지(author, "임시 저장 공지", BASE_PUBLISHED_AT.plusDays(1));
            noticeFixture.보관된_공지(author, "보관된 공지", BASE_PUBLISHED_AT.plusDays(2));
            noticeFixture.삭제된_공지(author, "삭제된 공지", BASE_PUBLISHED_AT.plusDays(3));
            Notice newer = noticeFixture.게시된_공지(author, "최근 공지", BASE_PUBLISHED_AT.plusDays(4));

            // when
            NoticeDetailResponse olderResult = noticeQueryService.getNoticeDetail(older.getId());
            NoticeDetailResponse newerResult = noticeQueryService.getNoticeDetail(newer.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(olderResult.prev().id()).isEqualTo(newer.getId());
                softly.assertThat(newerResult.next().id()).isEqualTo(older.getId());
            });
        }

        @Test
        void 게시일이_같으면_id로_순서를_정한다() {
            // given
            Notice first = noticeFixture.게시된_공지(author, "먼저 등록된 공지", BASE_PUBLISHED_AT);
            Notice second = noticeFixture.게시된_공지(author, "나중에 등록된 공지", BASE_PUBLISHED_AT);

            // when
            NoticeDetailResponse firstResult = noticeQueryService.getNoticeDetail(first.getId());
            NoticeDetailResponse secondResult = noticeQueryService.getNoticeDetail(second.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(firstResult.prev().id()).isEqualTo(second.getId());
                softly.assertThat(firstResult.next()).isNull();
                softly.assertThat(secondResult.prev()).isNull();
                softly.assertThat(secondResult.next().id()).isEqualTo(first.getId());
            });
        }
    }
}
