abstract class ResponseResult<T> {
  ResponseResult();
}
class SuccessResponse<T>extends ResponseResult<T>{
  final T data;
  SuccessResponse(this.data);
}
class FailureResponse<T>extends ResponseResult<T>{
  final String error;
  FailureResponse(this.error);
}