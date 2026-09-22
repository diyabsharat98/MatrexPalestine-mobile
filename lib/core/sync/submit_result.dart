/// Result of an operation that may either complete against the server
/// immediately or be queued locally for later sync (spec section 2).
sealed class SubmitResult<T> {
  const SubmitResult();
}

class SubmitSynced<T> extends SubmitResult<T> {
  const SubmitSynced(this.data);

  final T data;
}

class SubmitQueued<T> extends SubmitResult<T> {
  const SubmitQueued(this.uuid);

  final String uuid;
}
