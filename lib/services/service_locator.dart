import 'api_service.dart';
import 'auth_service.dart';
import 'dashboard_service.dart';
import 'device_service.dart';
import 'energy_service.dart';
import 'inverter_service.dart';
import 'user_profile_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  late final ApiService apiService = ApiService();
  late final AuthService authService = AuthService(apiService);
  late final DeviceService deviceService = DeviceService(apiService);
  late final EnergyService energyService = EnergyService(apiService);
  late final InverterService inverterService = InverterService(apiService);
  late final DashboardService dashboardService = DashboardService(apiService);
  late final UserProfileService userProfileService = UserProfileService(apiService);
}
