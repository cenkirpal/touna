class ResponseApi<E> {
  bool error;
  String? msg;
  List<E>? result;
  ResponseApi({required this.error, this.result, this.msg});
}
