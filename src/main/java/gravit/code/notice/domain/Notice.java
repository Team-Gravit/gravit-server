package gravit.code.notice.domain;

import gravit.code.global.entity.BaseEntity;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.time.LocalDateTime;
import java.time.ZoneId;

import static gravit.code.notice.domain.NoticeStatus.DRAFT;
import static gravit.code.notice.domain.NoticeStatus.PUBLISHED;
import static java.time.temporal.ChronoUnit.MICROS;

@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
@Slf4j
public class Notice extends BaseEntity {

    private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");
    private static final int TITLE_MAX_SIZE = 50;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @Column(name = "title", nullable = false)
    private String title;
    
    // SIZE 커지면 Lob 사용 고려
    @Column(name = "content", nullable = false)
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

    @Builder
    private Notice (
            String title,
            String content,
            User author,
            NoticeStatus status,
            boolean pinned,
            LocalDateTime publishedAt
    ) {
        this.title = title;
        this.content = content;
        this.author = author;
        this.status = status;
        this.pinned = pinned;
        this.publishedAt = publishedAt;
    }

    public static Notice create(
            String title,
            String content,
            User author,
            NoticeStatus status,
            boolean pinned
    ) {
        validate(title, content, status, pinned);
        LocalDateTime publishedAt = getLocalDateTime(status);

        return Notice.builder()
                .title(title.trim())
                .content(content)
                .author(author)
                .status(status)
                .pinned(pinned)
                .publishedAt(publishedAt)
                .build();
    }

    public void update(
            String title,
            String content,
            NoticeStatus status,
            boolean pinned
    ) {
        validateTitle(title);
        validateContent(content);
        validateAndUpdateStatus(status);

        this.title = title;
        this.content = content;
        this.status = status;
        this.pinned = pinned;
    }

    private void validateAndUpdateStatus(NoticeStatus status) {
        NoticeStatus prevStatus = this.status;

        if(prevStatus != status) {
            switch (status){
                case PUBLISHED -> {
                    this.publishedAt = LocalDateTime.now(SEOUL).truncatedTo(MICROS);
                }
                case DRAFT -> {
                    throw new RestApiException(CustomErrorCode.NOTICE_STATUS_INVALID);
                }
            }
        }
    }

    private static LocalDateTime getLocalDateTime(NoticeStatus status) {
        if(status.equals(PUBLISHED)) {
            return LocalDateTime.now(SEOUL).truncatedTo(MICROS);
        }
        return null;
    }

    private static void validate(
            String title,
            String content,
            NoticeStatus status,
            boolean pinned) {
        validateTitle(title);
        validateContent(content);
        validatePinned(status, pinned);
    }

    private static void validateTitle(String title) {
        if(title == null || title.isBlank()){
            throw new RestApiException(CustomErrorCode.NOTICE_TITLE_INVALID);
        }

        if(title.trim().length() > TITLE_MAX_SIZE){
            throw new RestApiException(CustomErrorCode.NOTICE_TITLE_INVALID);
        }
    }

    private static void validateContent(String content) {
        if(content == null || content.trim().isEmpty()){
            throw new RestApiException(CustomErrorCode.NOTICE_CONTENT_INVALID);
        }
    }

    private static void validatePinned(
            NoticeStatus status,
            boolean pinned
    ) {
        if(pinned && status.equals(DRAFT)){
            throw new RestApiException(CustomErrorCode.NOTICE_PINNED_MUST_BE_PUBLISHED);
        }
    }
}
