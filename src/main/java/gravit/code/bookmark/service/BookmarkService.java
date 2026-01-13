package gravit.code.bookmark.service;

import gravit.code.bookmark.domain.Bookmark;
import gravit.code.bookmark.repository.BookmarkRepository;
import gravit.code.bookmark.dto.request.BookmarkDeleteRequest;
import gravit.code.bookmark.dto.request.BookmarkSaveRequest;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.dto.response.ProblemDetail;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BookmarkService {

    private final BookmarkRepository bookmarkRepository;

    @Transactional
    public void addBookmark(
            long userId,
            BookmarkSaveRequest request
    ){
        if(bookmarkRepository.existsByProblemIdAndUserId(request.problemId(), userId))
            throw new RestApiException(CustomErrorCode.BOOKMARK_DUPLICATED);

        Bookmark bookmark = Bookmark.create(
                request.problemId(),
                userId
        );

        bookmarkRepository.save(bookmark);
    }

    @Transactional
    public void deleteBookmark(
            long userId,
            BookmarkDeleteRequest request
    ) {
        if(!bookmarkRepository.existsByProblemIdAndUserId(request.problemId(), userId))
            throw new RestApiException(CustomErrorCode.BOOKMARK_NOT_FOUND);

        bookmarkRepository.deleteByProblemIdAndUserId(request.problemId(), userId);
    }

    @Transactional(readOnly = true)
    public boolean checkBookmarkedProblemExists(
            long userId,
            long unitId
    ) {
        return bookmarkRepository.countByUnitIdAndUserId(unitId, userId) != 0;
    }

    @Transactional(readOnly = true)
    public List<ProblemDetail> getAllBookmarkedProblemInUnit(
            long userId,
            long unitId
    ){
        return bookmarkRepository.findBookmarkedProblemDetailByUnitIdAndUserId(unitId, userId);
    }
}
