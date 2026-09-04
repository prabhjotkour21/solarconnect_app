import 'api_service.dart';
import 'auth_service.dart';
import 'dashboard_service.dart';
import 'device_service.dart';
import 'energy_service.dart';
import 'inverter_service.dart';
import 'insights_service.dart';
import 'notification_service.dart';
import 'power_cut_service.dart';
import 'parameter_service.dart';
import 'savings_service.dart';
import 'settings_service.dart';
import 'socket_service.dart';
import 'user_profile_service.dart';
import 'wifi_config_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  late final ApiService apiService = ApiService();
  late final AuthService authService = AuthService(apiService);
  late final DeviceService deviceService = DeviceService(apiService);
  late final EnergyService energyService = EnergyService(apiService);
  late final InverterService inverterService = InverterService(apiService);
  late final DashboardService dashboardService = DashboardService(apiService);
  late final InsightsService insightsService = InsightsService(apiService);
  late final NotificationService notificationService = NotificationService(apiService);
  late final PowerCutService powerCutService = PowerCutService(apiService);
  late final ParameterService parameterService = ParameterService(apiService);
  late final SavingsService savingsService = SavingsService(apiService);
  late final SettingsService settingsService = SettingsService(apiService);
  late final SocketService socketService = SocketService();
  late final UserProfileService userProfileService = UserProfileService(apiService);
  late final WifiConfigService wifiConfigService = WifiConfigService(apiService);
}
