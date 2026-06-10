/// Named route constants for the entire app.
///
/// Never use raw strings like '/overview' in your code.
/// Always use AppRoutes.overview so refactoring is safe.
abstract class AppRoutes {
  static const String shell = '/';
  static const String overview = '/overview';
  static const String explore = '/explore';
  static const String articleDetail = '/article-detail';
  static const String me = '/me';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String systemDetails = '/system-details';
}
