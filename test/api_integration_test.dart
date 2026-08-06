import 'package:flutter_test/flutter_test.dart';
import 'package:solarconnect_app/services/auth_service.dart';
import 'package:solarconnect_app/services/api_service.dart';
import 'package:solarconnect_app/services/user_profile_service.dart';

void main() {
  group('API integration layer', () {
    test('services can be instantiated', () {
      final apiService = ApiService();
      final authService = AuthService(apiService);
      final profileService = UserProfileService(apiService);

      expect(authService, isNotNull);
      expect(profileService, isNotNull);
      expect(apiService, isNotNull);
    });
  });
}
