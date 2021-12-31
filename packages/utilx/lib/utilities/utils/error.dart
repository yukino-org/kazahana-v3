class ErrorInfo {
  const ErrorInfo(this.error, [this.stack]);

  final Object error;
  final StackTrace? stack;
}
