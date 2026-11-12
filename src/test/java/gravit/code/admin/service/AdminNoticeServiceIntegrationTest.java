package gravit.code.admin.service;

import gravit.code.admin.dto.request.NoticeCreateRequest;
import gravit.code.admin.dto.request.NoticeUpdateRequest;
import gravit.code.admin.dto.response.NoticeDetailResponse;
import gravit.code.admin.dto.response.NoticeListItemResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.notice.domain.NoticeStatus;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AdminNoticeServiceIntegrationTest {

    @Autowired
    private AdminNoticeService adminNoticeService;

    @Autowired
    private UserFixture userFixture;

    private long adminId;

    @BeforeEach
    void setUp() {
        User admin = userFixture.일반_유저(1);
        adminId = admin.getId();
    }

    @Test
    @DisplayName("공지 생성: PUBLISHED 면 publishedAt 세팅")
    void createNotice_published() {
        NoticeDetailResponse created = adminNoticeService.createNotice(adminId,
                new NoticeCreateRequest("제목", "요약", "본문", NoticeStatus.PUBLISHED, false));

        assertSoftly(softly -> {
            softly.assertThat(created.status()).isEqualTo(NoticeStatus.PUBLISHED);
            softly.assertThat(created.publishedAt()).isNotNull();
            softly.assertThat(created.summary()).isEqualTo("요약");
        });
    }

    @Test
    @DisplayName("공지 생성: DRAFT 면 publishedAt null")
    void createNotice_draft() {
        NoticeDetailResponse created = adminNoticeService.createNotice(adminId,
                new NoticeCreateRequest("제목", "요약", "본문", NoticeStatus.DRAFT, false));

        assertThat(created.status()).isEqualTo(NoticeStatus.DRAFT);
        assertThat(created.publishedAt()).isNull();
    }

    @Test
    @DisplayName("공지 생성: pinned + DRAFT 는 400")
    void createNotice_pinnedDraft() {
        assertThatThrownBy(() -> adminNoticeService.createNotice(adminId,
                new NoticeCreateRequest("제목", "요약", "본문", NoticeStatus.DRAFT, true)))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.NOTICE_PINNED_MUST_BE_PUBLISHED);
    }

    @Test
    @DisplayName("공지 생성: 작성 시 ARCHIVED 불가 (400)")
    void createNotice_archived() {
        assertThatThrownBy(() -> adminNoticeService.createNotice(adminId,
                new NoticeCreateRequest("제목", "요약", "본문", NoticeStatus.ARCHIVED, false)))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.NOTICE_STATUS_INVALID);
    }

    @Test
    @DisplayName("공지 상태 전이: PUBLISHED -> ARCHIVED 허용")
    void update_published_to_archived() {
        NoticeDetailResponse published = adminNoticeService.createNotice(adminId,
                new NoticeCreateRequest("제목", "요약", "본문", NoticeStatus.PUBLISHED, false));

        NoticeDetailResponse updated = adminNoticeService.updateNotice(adminId, published.noticeId(),
                new NoticeUpdateRequest(null, null, null, NoticeStatus.ARCHIVED, null));

        assertThat(updated.status()).isEqualTo(NoticeStatus.ARCHIVED);
    }

    @Test
    @DisplayName("공지 상태 전이: ARCHIVED -> PUBLISHED 차단 (409)")
    void update_archived_to_published_blocked() {
        NoticeDetailResponse published = adminNoticeService.createNotice(adminId,
                new NoticeCreateRequest("제목", "요약", "본문", NoticeStatus.PUBLISHED, false));
        adminNoticeService.updateNotice(adminId, published.noticeId(),
                new NoticeUpdateRequest(null, null, null, NoticeStatus.ARCHIVED, null));

        assertThatThrownBy(() -> adminNoticeService.updateNotice(adminId, published.noticeId(),
                new NoticeUpdateRequest(null, null, null, NoticeStatus.PUBLISHED, null)))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.NOTICE_INVALID_STATUS_TRANSITION);
    }

    @Test
    @DisplayName("공지 상태 전이: DRAFT -> ARCHIVED 차단 (409)")
    void update_draft_to_archived_blocked() {
        NoticeDetailResponse draft = adminNoticeService.createNotice(adminId,
                new NoticeCreateRequest("제목", "요약", "본문", NoticeStatus.DRAFT, false));

        assertThatThrownBy(() -> adminNoticeService.updateNotice(adminId, draft.noticeId(),
                new NoticeUpdateRequest(null, null, null, NoticeStatus.ARCHIVED, null)))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.NOTICE_INVALID_STATUS_TRANSITION);
    }

    @Test
    @DisplayName("공지 상태 전이: DRAFT -> PUBLISHED 시 publishedAt 세팅")
    void update_draft_to_published_setsPublishedAt() {
        NoticeDetailResponse draft = adminNoticeService.createNotice(adminId,
                new NoticeCreateRequest("제목", "요약", "본문", NoticeStatus.DRAFT, false));

        NoticeDetailResponse updated = adminNoticeService.updateNotice(adminId, draft.noticeId(),
                new NoticeUpdateRequest(null, null, null, NoticeStatus.PUBLISHED, null));

        assertThat(updated.status()).isEqualTo(NoticeStatus.PUBLISHED);
        assertThat(updated.publishedAt()).isNotNull();
    }

    @Test
    @DisplayName("공지 부분 수정: 미제공 필드는 유지")
    void update_partial_keepsFields() {
        NoticeDetailResponse created = adminNoticeService.createNotice(adminId,
                new NoticeCreateRequest("원제목", "원요약", "원본문", NoticeStatus.PUBLISHED, false));

        NoticeDetailResponse updated = adminNoticeService.updateNotice(adminId, created.noticeId(),
                new NoticeUpdateRequest("새제목", null, null, null, null));

        assertSoftly(softly -> {
            softly.assertThat(updated.title()).isEqualTo("새제목");
            softly.assertThat(updated.summary()).isEqualTo("원요약");
            softly.assertThat(updated.content()).isEqualTo("원본문");
            softly.assertThat(updated.status()).isEqualTo(NoticeStatus.PUBLISHED);
        });
    }

    @Test
    @DisplayName("공지 삭제(soft delete): 목록/상세에서 제외")
    void deleteNotice_softDelete() {
        NoticeDetailResponse created = adminNoticeService.createNotice(adminId,
                new NoticeCreateRequest("제목", "요약", "본문", NoticeStatus.PUBLISHED, false));

        adminNoticeService.deleteNotice(adminId, created.noticeId());

        PageResponse<NoticeListItemResponse> list = adminNoticeService.getNotices(1);
        assertThat(list.contents()).isEmpty();
        assertThatThrownBy(() -> adminNoticeService.getNotice(created.noticeId()))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.NOTICE_NOT_FOUND);
    }

    @Test
    @DisplayName("공지 목록 정렬: 핀 최상단(게시일 내림차순) → 비핀 최신순 → 미게시(DRAFT) 최후순, 페이지 경계 적용")
    void getNotices_ordering() {
        // 비핀 PUBLISHED 18건: 생성 순서대로 publishedAt 증가 (일반-00 이 가장 오래됨)
        for (int i = 0; i < 18; i++) {
            adminNoticeService.createNotice(adminId,
                    new NoticeCreateRequest("일반-%02d".formatted(i), "요약", "본문", NoticeStatus.PUBLISHED, false));
        }
        // 비핀 DRAFT 1건: publishedAt 이 null 이라 NULLS LAST 로 맨 뒤
        adminNoticeService.createNotice(adminId,
                new NoticeCreateRequest("드래프트", "요약", "본문", NoticeStatus.DRAFT, false));
        // 핀 PUBLISHED 3건: 가장 늦게 생성한 핀-2 가 게시일이 가장 최신
        for (int i = 0; i < 3; i++) {
            adminNoticeService.createNotice(adminId,
                    new NoticeCreateRequest("핀-%d".formatted(i), "요약", "본문", NoticeStatus.PUBLISHED, true));
        }

        // 총 22건 → 1페이지 20건, 2페이지 2건
        List<NoticeListItemResponse> page1 = adminNoticeService.getNotices(1).contents();
        List<NoticeListItemResponse> page2 = adminNoticeService.getNotices(2).contents();

        assertSoftly(softly -> {
            softly.assertThat(page1).hasSize(20);
            softly.assertThat(page2).hasSize(2);

            // 핀 공지(3건)는 모두 1페이지 최상단
            softly.assertThat(page1.stream().filter(NoticeListItemResponse::pinned).count()).isEqualTo(3L);
            softly.assertThat(page1.get(0).pinned()).isTrue();
            softly.assertThat(page1.get(1).pinned()).isTrue();
            softly.assertThat(page1.get(2).pinned()).isTrue();
            softly.assertThat(page1.get(3).pinned()).isFalse();

            // 핀 그룹 내부는 게시일 내림차순 (핀-2 > 핀-1 > 핀-0)
            softly.assertThat(page1.get(0).title()).isEqualTo("핀-2");
            softly.assertThat(page1.get(1).title()).isEqualTo("핀-1");
            softly.assertThat(page1.get(2).title()).isEqualTo("핀-0");
            softly.assertThat(page1.get(0).publishedAt()).isAfterOrEqualTo(page1.get(1).publishedAt());
            softly.assertThat(page1.get(1).publishedAt()).isAfterOrEqualTo(page1.get(2).publishedAt());

            // 핀 바로 아래는 비핀 중 가장 최근 게시분(일반-17)
            softly.assertThat(page1.get(3).title()).isEqualTo("일반-17");

            // 2페이지는 비핀만, 미게시 DRAFT 는 publishedAt null 로 가장 마지막
            softly.assertThat(page2.stream().anyMatch(NoticeListItemResponse::pinned)).isFalse();
            softly.assertThat(page2.get(0).title()).isEqualTo("일반-00");
            softly.assertThat(page2.get(0).publishedAt()).isNotNull();
            softly.assertThat(page2.get(1).title()).isEqualTo("드래프트");
            softly.assertThat(page2.get(1).publishedAt()).isNull();
        });
    }
}
