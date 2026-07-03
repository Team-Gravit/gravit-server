package gravit.code.inquiry.domain;

import gravit.code.global.entity.BaseEntity;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import static gravit.code.inquiry.domain.InquiryStatus.PENDING;
import static gravit.code.inquiry.domain.InquiryStatus.RESOLVED;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Inquiry extends BaseEntity {

    private static final int TITLE_MAX_SIZE = 50;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "title", nullable = false)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private InquiryType type;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private InquiryStatus status;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Builder(access = AccessLevel.PRIVATE)
    private Inquiry(
            String title,
            InquiryType type,
            String content,
            InquiryStatus status,
            long userId
    ) {
        this.title = title;
        this.type = type;
        this.content = content;
        this.status = status;
        this.userId = userId;
    }

    public static Inquiry create(
            String title,
            InquiryType type,
            String content,
            long userId
    ) {
        validateTitle(title);
        validateContent(content);

        return Inquiry.builder()
                .title(title.trim())
                .type(type)
                .content(content)
                .status(PENDING)
                .userId(userId)
                .build();
    }

    // 관리자 답변 등록 시 자동 완료 처리
    public void resolve() {
        this.status = RESOLVED;
    }

    // 관리자 답변 삭제 시 미답변 상태로 되돌린다
    public void reopen() {
        this.status = PENDING;
    }

    public boolean isOwnedBy(long userId) {
        return this.userId == userId;
    }

    private static void validateTitle(String title) {
        if (title == null || title.isBlank() || title.trim().length() > TITLE_MAX_SIZE) {
            throw new RestApiException(CustomErrorCode.INQUIRY_TITLE_INVALID);
        }
    }

    private static void validateContent(String content) {
        if (content == null || content.isBlank()) {
            throw new RestApiException(CustomErrorCode.INQUIRY_CONTENT_INVALID);
        }
    }
}
