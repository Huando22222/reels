class ResponseModel<T> {
  final bool success;
  final String msg;
  final String? code;
  final T? data;
  ResponseModel({
    required this.success,
    required this.msg,
    this.code,
    this.data,
  });

  factory ResponseModel.error({
    String? message,
    String? code,
  }) {
    return ResponseModel(
      success: false,
      msg: 'Failed: $message',
      code: code,
    );
  }
}
