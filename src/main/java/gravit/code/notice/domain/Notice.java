package gravit.code.notice.domain;

import gravit.code.global.consts.TimeZoneConst;
import gravit.code.global.entity.BaseEntity;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

import java.time.LocalDateTime;

import static gravit.code.notice.domain.NoticeStatus.*;
import static java.time.temporal.ChronoUnit.MICROS;

@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
@Slf4j
@SQLDelete(sql = "UPDATE notice SET deleted_at = NOW() WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
public class Notice extends BaseEntity {

    private static final int TITLE_MAX_SIZE = 50;
    private static final int SUMMARY_MAX_SIZE = 255;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "summary", nullable = false)
    private String summary;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    private User author;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NoticeStatus status;

    @Column(nullable = false)
    private boolean pinned;

    private LocalDateTime publishedAt;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @Builder(access = AccessLevel.PRIVATE)
    private Notice (
            String title,
            String summary,
            String content,
            User author,
            NoticeStatus status,
            boolean pinned,
            LocalDateTime publishedAt
    ) {
        this.title = title;
        this.summary = summary;
        this.content = content;
        this.author = author;
        this.status = status;
        this.pinned = pinned;
        this.publishedAt = publishedAt;
    }

    public static Notice create(
            String title,
            String summary,
            String content,
            User author,
            NoticeStatus status,
            boolean pinned
    ) {
        validateOnCreate(title, summary, content, status, pinned);
        LocalDateTime publishedAt = getLocalDateTime(status);

        return Notice.builder()
                .title(title.trim())
                .summary(summary)
                .content(content)
                .author(author)
                .status(status)
                .pinned(pinned)
                .publishedAt(publishedAt)
                .build();
    }

    public void update(
            String title,
            String summary,
            String content,
            NoticeStatus status,
            boolean pinned
    ) {
        validateTitle(title);
        validateSummary(summary);
        validateContent(content);
        validatePinned(status, pinned);
        validateAndUpdateStatus(status);

        this.title = title.trim();
        this.summary = summary;
        this.content = content;
        this.status = status;
        this.pinned = pinned;
    }

    private void validateAndUpdateStatus(NoticeStatus next) {
        NoticeStatus current = this.status;

        if (current == next) {
            return;
        }

        boolean allowed = switch (current) {
            case DRAFT -> next == PUBLISHED;             // DRAFT -> ARCHIVED 차단
            case PUBLISHED -> next == ARCHIVED;          // PUBLISHED -> DRAFT 차단
            case ARCHIVED -> false;                      // ARCHIVED -> 무엇이든 차단
        };

        if (!allowed) {
            throw new RestApiException(CustomErrorCode.NOTICE_INVALID_STATUS_TRANSITION);
        }

        if (next == PUBLISHED && this.publishedAt == null) {
            this.publishedAt = LocalDateTime.now(TimeZoneConst.KST).truncatedTo(MICROS);
        }
    }

    private static LocalDateTime getLocalDateTime(NoticeStatus status) {
        if (status == PUBLISHED) {
            return LocalDateTime.now(TimeZoneConst.KST).truncatedTo(MICROS);
        }
        return null;
    }

    private static void validateOnCreate(
            String title,
            String summary,
            String content,
            NoticeStatus status,
            boolean pinned
    ) {
        validateTitle(title);
        validateSummary(summary);
        validateContent(content);
        validateCreatableStatus(status);
        validatePinned(status, pinned);
    }

    private static void validateCreatableStatus(NoticeStatus status) {
        if (status == ARCHIVED) {                        // 작성 시 ARCHIVED 불가
            throw new RestApiException(CustomErrorCode.NOTICE_STATUS_INVALID);
        }
    }

    private static void validateTitle(String title) {
        if (title == null || title.isBlank()) {
            throw new RestApiException(CustomErrorCode.NOTICE_TITLE_INVALID);
        }

        if (title.trim().length() > TITLE_MAX_SIZE) {
            throw new RestApiException(CustomErrorCode.NOTICE_TITLE_INVALID);
        }
    }

    private static void validateSummary(String summary) {
        if (summary == null || summary.isBlank()) {
            throw new RestApiException(CustomErrorCode.NOTICE_SUMMARY_INVALID);
        }

        if (summary.length() > SUMMARY_MAX_SIZE) {
            throw new RestApiException(CustomErrorCode.NOTICE_SUMMARY_INVALID);
        }
    }

    private static void validateContent(String content) {
        if (content == null || content.trim().isEmpty()) {
            throw new RestApiException(CustomErrorCode.NOTICE_CONTENT_INVALID);
        }
    }

    private static void validatePinned(
            NoticeStatus status,
            boolean pinned
    ) {
        if (pinned && status == DRAFT) {
            throw new RestApiException(CustomErrorCode.NOTICE_PINNED_MUST_BE_PUBLISHED);
        }
    }
}
