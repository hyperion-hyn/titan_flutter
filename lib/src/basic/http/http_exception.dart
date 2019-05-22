class HttpResponseNot200Exception implements Exception {
  String cause;

  HttpResponseNot200Exception(this.cause);

  @override
  String toString() {
    return "HttpResponseNot200Exception: $cause";
  }
}

class HttpResponseCodeNotSuccess implements Exception {
  String cause;

  HttpResponseCodeNotSuccess(this.cause);

  @override
  String toString() {
    return "HttpResponseCodeNotSuccess: $cause";
  }
}
