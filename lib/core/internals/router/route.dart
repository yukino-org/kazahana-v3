abstract class InternalRoute {
  bool matches(final String route);
  Future<void> handle(final String route);
}
