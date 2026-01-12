package gravit.code.bookmark.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.bookmark.dto.request.BookmarkDeleteRequest;
import gravit.code.bookmark.dto.request.BookmarkSaveRequest;
import gravit.code.bookmark.facade.BookmarkFacade;
import gravit.code.bookmark.service.BookmarkService;
import gravit.code.problem.dto.response.BookmarkedProblemResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/bookmarks")
public class BookmarkController implements BookmarkControllerDocs {

    private final BookmarkFacade bookmarkFacade;
    private final BookmarkService bookmarkService;

    @GetMapping("/{unitId}")
    public ResponseEntity<BookmarkedProblemResponse> getAllBookmarkedProblemInUnit(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("unitId") Long unitId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(bookmarkFacade.getAllBookmarkedProblemInUnit(loginUser.getId(), unitId));
    }

    @PostMapping
    public ResponseEntity<Void> addBookmark(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody BookmarkSaveRequest request
    ){
        bookmarkService.addBookmark(loginUser.getId(), request);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> deleteBookmark(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid@RequestBody BookmarkDeleteRequest request
    ) {
        bookmarkService.deleteBookmark(loginUser.getId(), request);
        return ResponseEntity.noContent().build();
    }

}
