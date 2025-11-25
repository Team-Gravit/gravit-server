package gravit.code.global.exception.handler;

import gravit.code.user.exception.AccountSoftDeletedException;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.ErrorCode;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.global.exception.domain.RestApiException;
import lombok.extern.log4j.Log4j2;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.View;

import java.util.ArrayList;
import java.util.List;

@Log4j2
@RestControllerAdvice
public class GlobalExceptionHandler {

    private final View error;

    public GlobalExceptionHandler(View error) {
        this.error = error;
    }

    @ExceptionHandler(RestApiException.class)
    public ResponseEntity<ErrorResponse<String>> handleRestApiException(RestApiException e){

        ErrorCode errorCode = e.getErrorCode();

        return handleExceptionInternal(errorCode);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse<List<String>>> handleValidException(MethodArgumentNotValidException e) {
        BindingResult result = e.getBindingResult();
        List<String> errorMessages = new ArrayList<>();

        log.error("@Valid Exception occur with below parameter");
        for (FieldError error : result.getFieldErrors()) {
            String errorMessage = "[ " + error.getField() + " ]" +
                    "[ " + error.getDefaultMessage() + " ]" +
                    "[ " + error.getRejectedValue() + " ]";
            errorMessages.add(errorMessage);
        }

        return handleExceptionInternal(errorMessages);
    }

    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<ErrorResponse<String>> handleDatabaseException(DataAccessException e){
        ErrorCode errorCode = CustomErrorCode.DATABASE_EXCEPTION;

        log.error("DataAccessException occur with: {}", e.getMessage());

        return handleExceptionInternal(errorCode);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse<String>> handleException(Exception e){

        log.error("예외 발생 :", e);
        ErrorCode errorCode = CustomErrorCode.INTERNAL_SERVER_ERROR;

        return handleExceptionInternal(errorCode);
    }

    @ExceptionHandler(AccountSoftDeletedException.class)
    public ResponseEntity<ErrorResponse<String>> handleSoftDeleted(AccountSoftDeletedException ex) {
        String errorCode = "USER_423";
        String message = ex.getProviderId();
        ErrorResponse<String> errorResponse = ErrorResponse.<String>builder()
                .error(errorCode)
                .message(message)
                .build();
        HttpStatus status = HttpStatus.LOCKED;
        return ResponseEntity.status(status).body(errorResponse);
    }

    private ResponseEntity<ErrorResponse<String>> handleExceptionInternal(ErrorCode errorCode) {
        return ResponseEntity.status(errorCode.getHttpStatus())
                .body(makeErrorResponse(errorCode));
    }

    private ResponseEntity<ErrorResponse<List<String>>> handleExceptionInternal(List<String> message) {
        return ResponseEntity.status(CustomErrorCode.INVALID_PARAMS.getHttpStatus())
                .body(makeErrorResponse(message));
    }

    private ErrorResponse<String> makeErrorResponse(ErrorCode errorCode){
        return ErrorResponse.<String>builder()
                .error(errorCode.getCode())
                .message(errorCode.getMessage())
                .build();
    }

    private ErrorResponse<List<String>> makeErrorResponse(List<String> message){
        return ErrorResponse.<List<String>>builder()
                .error(CustomErrorCode.INVALID_PARAMS.getCode())
                .message(message)
                .build();
    }
}
