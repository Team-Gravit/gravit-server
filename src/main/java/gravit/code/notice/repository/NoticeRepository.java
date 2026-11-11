package gravit.code.notice.repository;

import gravit.code.notice.domain.Notice;
import gravit.code.notice.domain.NoticeStatus;
import gravit.code.notice.dto.response.NoticeNeighborResponse;
import gravit.code.notice.dto.response.NoticeSummaryResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;

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

    @Query("""
            select n
            from Notice n
            order by n.pinned desc, n.publishedAt desc nulls last, n.createdAt desc
    """)
    Page<Notice> findAllForAdmin(Pageable pageable);

    Optional<Notice> findByIdAndStatus(
            long id,
            NoticeStatus status
    );

    @Query("""
            SELECT new gravit.code.notice.dto.response.NoticeNeighborResponse(n.id, n.title)
            FROM Notice n
            WHERE n.status = :status
              AND n.pinned = false
              AND (n.publishedAt > :publishedAt OR (n.publishedAt = :publishedAt AND n.id > :id))
            ORDER BY n.publishedAt ASC, n.id ASC
            LIMIT 1
    """)
    Optional<NoticeNeighborResponse> findNewerNeighbor(
            @Param("status") NoticeStatus status,
            @Param("publishedAt") LocalDateTime publishedAt,
            @Param("id") long id
    );

    @Query("""
            SELECT new gravit.code.notice.dto.response.NoticeNeighborResponse(n.id, n.title)
            FROM Notice n
            WHERE n.status = :status
              AND n.pinned = false
              AND (n.publishedAt < :publishedAt OR (n.publishedAt = :publishedAt AND n.id < :id))
            ORDER BY n.publishedAt DESC, n.id DESC
            LIMIT 1
    """)
    Optional<NoticeNeighborResponse> findOlderNeighbor(
            @Param("status") NoticeStatus status,
            @Param("publishedAt") LocalDateTime publishedAt,
            @Param("id") long id
    );
}
