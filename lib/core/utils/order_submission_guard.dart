class OrderSubmissionGuard<T> {
  final Map<String, Future<T>> _requests = {};
  Future<T> submit(String requestId, Future<T> Function() create) =>
      _requests.putIfAbsent(requestId, create);
}
