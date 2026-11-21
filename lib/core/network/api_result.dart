
sealed class ApiResult<T> {}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  ApiSuccess(this.data);
}

class ApiError extends ApiResult<Never> {
  final String message;
  ApiError(this.message);
}
