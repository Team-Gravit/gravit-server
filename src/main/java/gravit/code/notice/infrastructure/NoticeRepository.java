package gravit.code.notice.infrastructure;

import gravit.code.notice.domain.Notice;
import gravit.code.notice.domain.NoticeStatus;
import gravit.code.notice.dto.response.NoticeSummaryResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface NoticeRepository extends JpaRepository<Notice, Long> {

    @Query("""
        select new gravit.code.notice.dto.response.NoticeSummaryResponse(
            n.id,
            n.title,
            case when length(n.content) > :limit
                 then concat(substring(n.content, 1, :limit - 1), '…')
                 else n.content end,
            n.pinned,
            n.publishedAt
        )
        from Notice n
        where n.status = :status
        """)
    Page<NoticeSummaryResponse> findSummaries(
            @Param("status") NoticeStatus status,
            @Param("limit") int limit,
            Pageable pageable
    );
}
