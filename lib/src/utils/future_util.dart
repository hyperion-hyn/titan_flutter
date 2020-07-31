typedef Future<T> FutureGenerator<T>();

Future<T> futureRetry<T>(int retryNum, FutureGenerator reFuture) async {
  try {
    return await reFuture();
  } catch (e) {
    if (retryNum > 1) {
      return futureRetry(retryNum - 1, reFuture);
    }
    rethrow;
  }
}