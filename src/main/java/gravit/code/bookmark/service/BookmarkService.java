package gravit.code.bookmark.service;

import gravit.code.bookmark.domain.Bookmark;
import gravit.code.bookmark.domain.BookmarkRepository;
import gravit.code.bookmark.dto.request.BookmarkDeleteRequest;
import gravit.code.bookmark.dto.request.BookmarkSaveRequest;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class BookmarkService {

    private final BookmarkRepository bookmarkRepository;

    @Transactional
    public void saveBookmark(
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
}
