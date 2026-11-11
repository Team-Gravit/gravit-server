package gravit.code.notice.fixture;

import gravit.code.notice.domain.Notice;
import gravit.code.notice.domain.NoticeStatus;
import gravit.code.notice.repository.NoticeRepository;
import gravit.code.user.domain.User;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDateTime;

@TestComponent
@RequiredArgsConstructor
public class NoticeFixture {

    private static final String SUMMARY = "요약";
    private static final String CONTENT = "본문";

    private final NoticeRepository noticeRepository;

    public Notice 게시된_공지(
            User author,
            String title,
            LocalDateTime publishedAt
    ) {
        Notice notice = Notice.create(title, SUMMARY, CONTENT, author, NoticeStatus.PUBLISHED, false);
        ReflectionTestUtils.setField(notice, "publishedAt", publishedAt);
        return noticeRepository.save(notice);
    }

    public Notice 고정_공지(
            User author,
            String title,
            LocalDateTime publishedAt
    ) {
        Notice notice = Notice.create(title, SUMMARY, CONTENT, author, NoticeStatus.PUBLISHED, true);
        ReflectionTestUtils.setField(notice, "publishedAt", publishedAt);
        return noticeRepository.save(notice);
    }

    public Notice 게시일이_있는_임시_저장_공지(
            User author,
            String title,
            LocalDateTime publishedAt
    ) {
        Notice notice = Notice.create(title, SUMMARY, CONTENT, author, NoticeStatus.DRAFT, false);
        ReflectionTestUtils.setField(notice, "publishedAt", publishedAt);
        return noticeRepository.save(notice);
    }

    public Notice 보관된_공지(
            User author,
            String title,
            LocalDateTime publishedAt
    ) {
        Notice notice = Notice.create(title, SUMMARY, CONTENT, author, NoticeStatus.PUBLISHED, false);
        ReflectionTestUtils.setField(notice, "publishedAt", publishedAt);
        notice.update(title, SUMMARY, CONTENT, NoticeStatus.ARCHIVED, false);
        return noticeRepository.save(notice);
    }

    public Notice 삭제된_공지(
            User author,
            String title,
            LocalDateTime publishedAt
    ) {
        Notice notice = 게시된_공지(author, title, publishedAt);
        noticeRepository.delete(notice);
        return notice;
    }
}
