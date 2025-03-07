class ApiResponse<T> {
  final T? data;
  final bool isSuccess;
  final int? statusCode;
  final String? message;

  ApiResponse({
    this.data,
    required this.isSuccess,
    this.statusCode,
    this.message,
  });

  //:::::::::::::::::::::::<< Factory Method For a Successful Response >>:::::::::::::::::::::://
  factory ApiResponse.success(T data, {int? statusCode, String? message}) {
    return ApiResponse(
      data: data,
      isSuccess: true,
      statusCode: statusCode,
      message: message,
    );
  }

  //:::::::::::::::::::::::<< Factory Method For an Error Response >>:::::::::::::::::::::://
  factory ApiResponse.error({int? statusCode, String? message, T? data}) {
    return ApiResponse(
      data: data,
      isSuccess: false,
      statusCode: statusCode,
      message: message,
    );
  }

  @override
  String toString() {
    return 'ApiResponse { isSuccess: $isSuccess, statusCode: $statusCode, message: $message, data: $data }';
  }
}
