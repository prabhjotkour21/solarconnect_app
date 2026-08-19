import 'api_service.dart';

class SavingsService {
  SavingsService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> getSummary(
    String token, {
    String period = 'monthly',
    double tariff = 8,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'period': period,
      'tariff': tariff,
      if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
      if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
    };

    return _apiService.get('/savings', queryParams: queryParams, token: token);
  }

  Future<Map<String, dynamic>> getTrend(
    String token, {
    String filter = 'weekly',
    double tariff = 8,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'filter': filter,
      'tariff': tariff,
      if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
      if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
    };

    return _apiService.get('/savings/trend', queryParams: queryParams, token: token);
  }

  Future<Map<String, dynamic>> updateInvestmentAmount(
    String token,
    double investmentAmount,
  ) async {
    return _apiService.put(
      '/savings/user/investment',
      body: {'investmentAmount': investmentAmount},
      token: token,
    );
  }
}
