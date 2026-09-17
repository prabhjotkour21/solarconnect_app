import 'package:flutter/material.dart';
import '../models/configuration_transfer.dart';
import '../models/device_parameter.dart';
import '../services/service_locator.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../validation/parameter_validation.dart';

class DeviceConfigurationScreen extends StatefulWidget {
  const DeviceConfigurationScreen({super.key});
  @override
  State<DeviceConfigurationScreen> createState() => _DeviceConfigurationScreenState();
}

class _DeviceConfigurationScreenState extends State<DeviceConfigurationScreen> {
  List<Map<String, dynamic>> _devices = [];
  List<DeviceParameter> _parameters = [];
  Map<int, dynamic> _editedValues = {};
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, String?> _validationErrors = {};
  Map<String, dynamic> _status = {};
  String? _selectedDeviceId;
  bool _loading = true;
  String? _error;
  String? _sendMessage;
  bool _sending = false;
  ConfigurationTransferStatus _transferStatus = ConfigurationTransferStatus.idle;
  final List<TransferErrorHistoryEntry> _errorHistory = <TransferErrorHistoryEntry>[];
  String _transferMessage = 'Change parameters and press Send to send validated values.';
  String? _transferError;
  bool get _hasChanges => _editedValues.isNotEmpty;
  bool get _canSend => _hasChanges && !_sending && _validationErrors.values.every((error) => error == null);
  bool get _deviceReady {
    final evaluation = TransferDeviceStatusEvaluator.evaluate(
      _status,
      requireTransferReady: false,
    );
    return evaluation.isReady;
  }

  @override
  void initState() { super.initState(); _loadDevices(); }

  Future<void> _loadDevices() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await ServiceLocator.instance.authService.getStoredToken();
      if (token == null || token.isEmpty) throw Exception('Authentication required.');
      final response = await ServiceLocator.instance.deviceService.getDevices(token);
      final raw = response['data'] is List ? response['data'] : response['devices'] is List ? response['devices'] : response;
      _devices = raw is List ? raw.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList() : [];
      if (_devices.isNotEmpty) await _selectDevice(_deviceId(_devices.first), token);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  String _deviceId(Map<String, dynamic> device) => (device['id'] ?? device['_id'] ?? '').toString();

  Future<void> _selectDevice(String id, [String? knownToken]) async {
    final token = knownToken ?? await ServiceLocator.instance.authService.getStoredToken();
    if (token == null || token.isEmpty || id.isEmpty) return;
    for (final controller in _controllers.values) controller.dispose();
    _controllers.clear();
    setState(() { _selectedDeviceId = id; _loading = true; _error = null; _sendMessage = null; _editedValues = {}; _validationErrors.clear(); });
    try {
      final results = await Future.wait([
        ServiceLocator.instance.parameterService.loadDefinitions(id, token),
        ServiceLocator.instance.parameterService.getCurrentValues(id, token),
        ServiceLocator.instance.deviceService.getConnectionStatus(id, token),
      ]);
      final definitions = _items(results[0]);
      final values = {for (final item in _items(results[1])) '${item['parameterNumber']}': item};
      final merged = definitions.map((definition) {
        final value = values['${definition['parameterNumber']}'];
        return DeviceParameter.fromJson({...definition, if (value != null) ...value});
      }).toList();
      if (mounted) setState(() { _parameters = merged; _status = results[2]; });
    } catch (error) {
      if (mounted) setState(() { _error = error.toString().replaceFirst('Exception: ', ''); _parameters = []; });
    } finally { if (mounted) setState(() => _loading = false); }
  }

  List<Map<String, dynamic>> _items(Map<String, dynamic> response) {
    final items = response['parameters'] ?? response['data'];
    return items is List ? items.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList() : [];
  }

  String _display(dynamic value) => value == null ? '-' : '$value';

  TextEditingController _controllerFor(DeviceParameter parameter) {
    return _controllers.putIfAbsent(parameter.parameterNumber, () => TextEditingController(text: parameter.currentValue == null ? '' : '${parameter.currentValue}'));
  }

  dynamic _typedValue(DeviceParameter parameter, String text) {
    final type = parameter.dataType.toUpperCase();
    if (type == 'BOOL' || type == 'BOOLEAN') return text.trim().toLowerCase() == 'true';
    if (type.startsWith('INT') || type.startsWith('UINT') || type == 'INTEGER') return int.tryParse(text.trim()) ?? text.trim();
    if (type.startsWith('FLOAT') || type == 'DOUBLE' || type == 'DECIMAL') return double.tryParse(text.trim()) ?? text.trim();
    return text;
  }

  void _changeValue(DeviceParameter parameter, String text) {
    final error = ParameterValidator.validate(parameter, text);
    final value = _typedValue(parameter, text);
    final original = parameter.currentValue ?? parameter.lastSentValue;
    setState(() {
      _validationErrors[parameter.parameterNumber] = error;
      if ('$value' == '$original' && text.trim().isNotEmpty) _editedValues.remove(parameter.parameterNumber); else _editedValues[parameter.parameterNumber] = value;
    });
  }

  void _clearValue(DeviceParameter parameter) {
    _controllerFor(parameter).clear();
    _changeValue(parameter, '');
  }

  void _registerTransferError(String code, {String? message, bool manualActionRequired = false}) {
    final reason = TransferFailureReason.fromCode(code);
    final finalMessage = message ?? reason.message;
    _errorHistory.insert(0, TransferErrorHistoryEntry(
      code: reason.code,
      message: finalMessage,
      timestamp: DateTime.now(),
    ));
    if (_errorHistory.length > 5) {
      _errorHistory.removeRange(5, _errorHistory.length);
    }
    if (manualActionRequired || reason.requiresManualAction) {
      _transferStatus = ConfigurationTransferStatus.failed;
      _transferError = finalMessage;
      _transferMessage = 'Manual action required';
    }
  }

  void _handlePreTransferStatus() {
    final evaluation = TransferDeviceStatusEvaluator.evaluate(
      _status,
      requireTransferReady: false,
    );
    if (!evaluation.isReady) {
      _registerTransferError(evaluation.failureCode ?? 'DEVICE_INACTIVE', message: evaluation.message, manualActionRequired: evaluation.failureCode == 'DEVICE_INACTIVE');
      setState(() {
        _transferStatus = ConfigurationTransferStatus.failed;
        _transferError = evaluation.message;
        _transferMessage = 'Device unavailable';
        _sending = false;
      });
      return;
    }
  }

  void _handleTransferFailure(String code, {String? overrideMessage}) {
    final reason = TransferFailureReason.fromCode(code);
    final message = overrideMessage ?? reason.message;
    _registerTransferError(code, message: message, manualActionRequired: reason.requiresManualAction);
    final policy = TransferRetryPolicy();
    final shouldRetry = policy.shouldRetry(reason);

    setState(() {
      _sending = false;
      _transferStatus = shouldRetry ? ConfigurationTransferStatus.retryPending : ConfigurationTransferStatus.failed;
      _transferError = message;
      _transferMessage = shouldRetry ? 'The value can be retried after the device is ready.' : 'Value send failed';
    });
  }

  Future<void> _sendParameters() async {
    for (final parameter in _parameters) _changeValue(parameter, _controllerFor(parameter).text);
    if (!_canSend || _selectedDeviceId == null) return;
    _handlePreTransferStatus();
    if (!mounted || !_deviceReady) return;
    setState(() {
      _sending = true;
      _sendMessage = null;
      _transferError = null;
      _transferStatus = ConfigurationTransferStatus.transferring;
      _transferMessage = 'Validating values and sending them to ESP32...';
    });
    try {
      final token = await ServiceLocator.instance.authService.getStoredToken();
      if (token == null || token.isEmpty) throw Exception('Authentication required.');
      final items = _parameters.where((parameter) => _controllerFor(parameter).text.trim().isNotEmpty).map((parameter) => {'parameterNumber': parameter.parameterNumber, 'value': _typedValue(parameter, _controllerFor(parameter).text)}).toList();
      final response = await ServiceLocator.instance.parameterService.validateParameters(_selectedDeviceId!, token, items);
      if (response['valid'] != true) throw Exception('One or more parameter values failed server validation.');
      final changed = items.where((item) => _editedValues.containsKey(item['parameterNumber'])).toList();
      if (changed.isEmpty) throw Exception('No changed parameter values to send.');
      for (final item in changed) {
        final result = await ServiceLocator.instance.parameterService.sendParameter(
          _selectedDeviceId!,
          token,
          parameterNumber: item['parameterNumber'] as int,
          value: '${item['value']}',
        );
        if (result['status']?.toString().toUpperCase() != 'APPLIED') {
          throw Exception(result['message']?.toString() ?? 'ESP32 rejected the parameter value.');
        }
      }
      if (mounted) setState(() {
        _sending = false;
        _transferStatus = ConfigurationTransferStatus.completed;
        _transferMessage = 'ESP32 acknowledged all parameter values.';
        _sendMessage = 'Values sent successfully.';
        _editedValues.clear();
      });
    } catch (error) {
      if (mounted) setState(() {
        _transferStatus = ConfigurationTransferStatus.failed;
        _transferError = error.toString().replaceFirst('Exception: ', '');
        _transferMessage = 'ESP32 value send failed.';
        _sendMessage = _transferError;
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() { for (final controller in _controllers.values) controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? selected;
    for (final device in _devices) { if (_deviceId(device) == _selectedDeviceId) selected = device; }
    return Scaffold(
      appBar: AppBar(title: const Text('Device Configuration')),
      body: RefreshIndicator(onRefresh: _loadDevices, child: ListView(padding: const EdgeInsets.all(16), children: [
        if (_loading && _devices.isEmpty) const LinearProgressIndicator(),
        if (_error != null) _Message(text: _error!, onRetry: _loadDevices),
        if (_devices.isEmpty && !_loading && _error == null) const _Message(text: 'No devices registered.'),
        if (_devices.isNotEmpty) DropdownButtonFormField<String>(
          value: _selectedDeviceId,
          decoration: const InputDecoration(labelText: 'Select device', prefixIcon: Icon(Icons.memory_rounded)),
          items: _devices.map((device) => DropdownMenuItem(value: _deviceId(device), child: Text('${device['name'] ?? device['serialNumber'] ?? _deviceId(device)}'))).toList(),
          onChanged: (id) { if (id != null) _selectDevice(id); },
        ),
        if (selected != null) _StatusSection(device: selected!, status: _status),
        if (_errorHistory.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Recent error history', style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            ..._errorHistory.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text('${entry.code}: ${entry.message}')),
                Text('${entry.timestamp.toLocal().toString().split(' ')[1].substring(0, 5)}', style: AppTextStyles.bodySmall),
              ]),
            )),
          ]))),
        ],
        if (_loading && _devices.isNotEmpty) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
        if (!_loading && _parameters.isNotEmpty) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Parameters', style: AppTextStyles.headingSmall), Text(_hasChanges ? '${_editedValues.length} modified' : 'No changes', style: TextStyle(color: _hasChanges ? AppColors.warning : AppColors.success))]),
          const SizedBox(height: 8), ..._parameters.map(_parameterTile),
          const SizedBox(height: 8),
          if (_sendMessage != null) Text(_sendMessage!, style: TextStyle(color: _sendMessage!.startsWith('All') ? AppColors.success : AppColors.error)),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: _canSend ? _sendParameters : null, icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded), label: const Text('Send'))),
          const SizedBox(height: 12),
          _ParameterSendStatus(status: _transferStatus, message: _transferMessage, error: _transferError),
        ],
      ])),
    );
  }

  Widget _parameterTile(DeviceParameter parameter) {
    final changed = _editedValues.containsKey(parameter.parameterNumber);
    final controller = _controllerFor(parameter);
    final error = _validationErrors[parameter.parameterNumber];
    return Card(color: changed ? AppColors.primary.withValues(alpha: .12) : null, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text('#${parameter.parameterNumber}', style: AppTextStyles.labelSmall), const SizedBox(width: 8), Expanded(child: Text('${parameter.parameterName}${parameter.isRequired ? ' *' : ''}', style: AppTextStyles.headingSmall)), if (changed) const Icon(Icons.edit_rounded, size: 16, color: AppColors.warning)]),
      Text('${parameter.dataType}  ${parameter.unit ?? ''}  |  ${_display(parameter.minValue)} - ${_display(parameter.maxValue)}', style: AppTextStyles.bodySmall),
      const SizedBox(height: 8),
      TextFormField(controller: controller, keyboardType: _isTextParameter(parameter) ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true), onChanged: (text) => _changeValue(parameter, text), decoration: InputDecoration(labelText: 'Current value', helperText: 'Last sent: ${_display(parameter.lastSentValue)}', errorText: error, errorMaxLines: 2, suffixIcon: IconButton(tooltip: 'Clear value', onPressed: controller.text.isEmpty ? null : () => _clearValue(parameter), icon: const Icon(Icons.clear_rounded))),),
    ])));
  }

  bool _isTextParameter(DeviceParameter parameter) {
    final type = parameter.dataType.toUpperCase();
    return type == 'STRING' || type == 'TEXT' || type == 'BOOL' || type == 'BOOLEAN';
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.device, required this.status});
  final Map<String, dynamic> device;
  final Map<String, dynamic> status;
  @override
  Widget build(BuildContext context) {
    final online = status['isOnline'] == true || status['connectionStatus'] == 'online';
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Device status', style: AppTextStyles.headingSmall), const SizedBox(height: 10),
      Text('Name: ${device['name'] ?? device['serialNumber'] ?? 'Unnamed device'}'), Text('Device ID: ${device['id'] ?? device['_id'] ?? '-'}'),
      Text('Connection: ${online ? 'Online' : (status['connectionStatus'] ?? device['status'] ?? 'Unknown')}'),
      Text('Status: ${status['status'] ?? status['deviceStatus'] ?? device['status'] ?? 'Unknown'}'),
      Text('Parameter send readiness: ${TransferDeviceStatusEvaluator.evaluate(status, requireTransferReady: false).message}'),
      Text('Last heartbeat: ${status['lastHeartbeatAt'] ?? 'Not available'}'),
      Text('Heartbeats: ${status['heartbeatCount'] ?? '-'}  |  Timeouts: ${status['timeoutCount'] ?? '-'}'),
    ])));
  }
}

class _ParameterSendStatus extends StatelessWidget {
  const _ParameterSendStatus({required this.status, required this.message, this.error});
  final ConfigurationTransferStatus status;
  final String message;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final color = status == ConfigurationTransferStatus.failed
        ? AppColors.error
        : status == ConfigurationTransferStatus.completed
            ? AppColors.success
            : AppColors.primary;
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(status == ConfigurationTransferStatus.completed ? Icons.check_circle_outline : Icons.send_rounded, color: color),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Parameter send status: ${status.label}', style: AppTextStyles.headingSmall),
        const SizedBox(height: 6),
        Text(message, style: TextStyle(color: color)),
        if (error != null) ...[const SizedBox(height: 6), Text(error!, style: TextStyle(color: AppColors.error))],
      ])),
    ])));
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});
  final String text; final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [Text(text), if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Retry'))])));
}