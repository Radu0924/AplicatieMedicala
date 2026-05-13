import 'dart:async';

import 'package:flutter/services.dart';

import '../models/models.dart';

/// Local PoC repository.
///
/// The app reads a bundled telemetry log and derives all mobile-facing state
/// from that file plus the MED-THERM-2026 constraints.
class MockRepository {
  MockRepository._();

  static final MockRepository instance = MockRepository._();

  static const String _logAssetPath =
      'assets/data/medical_device_logs_1000.txt';

  static const Transporter sampleTransporter = Transporter(
    id: 'poc-operator',
    fullName: 'Scenariu PoC Local',
    email: 'Date indisponibile in log',
    phone: 'Comunicare externa indisponibila',
  );

  static const Device sampleDevice = Device(
    id: 'cryosafe-ptu',
    code: 'CryoSafe PTU',
    tempMinOk: 2.0,
    tempMaxOk: 8.0,
    tempWarningThreshold: 7.0,
    dispatchPhone: 'Canal extern indisponibil in PoC',
  );

  final StreamController<TelemetrySnapshot> _controller =
      StreamController<TelemetrySnapshot>.broadcast();

  Stream<TelemetrySnapshot> get telemetryStream => _controller.stream;
  TelemetrySnapshot get current => _current;
  SessionMetrics get metrics => _metrics;
  bool get isLoaded => _isLoaded;
  Object? get loadError => _loadError;

  List<TelemetrySnapshot> getHistory() => List.unmodifiable(_history);
  List<TemperaturePoint> getTemperatureHistory() =>
      List.unmodifiable(_temperatureHistory);
  List<Transport> getPastTransports() => List.unmodifiable(pastTransports);
  List<AppNotification> getNotifications() => List.unmodifiable(_notifications);
  List<ComplianceCheck> getComplianceChecks() =>
      List.unmodifiable(_complianceChecks);

  ComplianceOverview get complianceOverview {
    var compliant = 0;
    var violations = 0;
    var insufficientData = 0;
    for (final check in _complianceChecks) {
      switch (check.state) {
        case ComplianceState.compliant:
          compliant++;
        case ComplianceState.violation:
          violations++;
        case ComplianceState.insufficientData:
          insufficientData++;
      }
    }
    return ComplianceOverview(
      total: _complianceChecks.length,
      compliant: compliant,
      violations: violations,
      insufficientData: insufficientData,
    );
  }

  Future<void> ensureLoaded() => _loadFuture ??= _load();

  AlertType? _acknowledgedAlert;
  AlertType? get acknowledgedAlert => _acknowledgedAlert;

  void acknowledgeAlert(AlertType alert) {
    _acknowledgedAlert = alert;
    _controller.add(_current);
  }

  void resetAlertAcknowledgement() {
    _acknowledgedAlert = null;
  }

  late Transport sampleTransport;
  late List<Transport> pastTransports;
  late TelemetrySnapshot _current = _emptySnapshot();
  late SessionMetrics _metrics = _emptyMetrics();
  final List<TelemetrySnapshot> _history = [];
  final List<TemperaturePoint> _temperatureHistory = [];
  final List<AppNotification> _notifications = [];
  final List<ComplianceCheck> _complianceChecks = [];
  bool _isLoaded = false;
  Object? _loadError;
  Future<void>? _loadFuture;

  Future<void> _load() async {
    try {
      final rawLog = await _readLog();
      final entries = _parseEntries(rawLog);
      if (entries.isEmpty) {
        throw StateError('Logul PoC nu contine evenimente valide.');
      }

      _temperatureHistory.clear();
      _history.clear();
      _notifications.clear();
      _complianceChecks.clear();

      final firstTimestamp = entries.first.timestamp;
      final lastTimestamp = entries.last.timestamp;

      var currentTemperature = sampleDevice.tempMinOk;
      var currentBattery = 100;
      var currentFanRpm = 0;
      var currentHumidity = 0;
      var currentVoltage = 0.0;
      var sensorPrimaryActive = true;
      var sensorSecondaryActive = true;
      var doorOpen = false;
      var online = true;
      var alarmsActive = 0;

      final recentEvents = <TelemetryEvent>[];
      final alarmTimestamps = <DateTime>[];
      final doorOpenTimestamps = <DateTime>[];
      final excursions = <_TemperatureExcursion>[];

      var minTemp = double.infinity;
      var maxTemp = double.negativeInfinity;
      var minBattery = double.infinity;
      var maxBattery = double.negativeInfinity;
      var overLimitCount = 0;
      DateTime? firstOverLimitAt;
      DateTime? prevEventTimestamp;
      DateTime? prevTempTimestamp;
      DateTime? currentExcursionStart;
      var rawEventGapMaxSeconds = 0;
      var temperatureGapMaxSeconds = 0;
      var temperatureGapsOver30Seconds = 0;
      var temperatureGapsOver90Seconds = 0;
      var tempReadingCount = 0;
      var tempWarningCount = 0;
      var alarmTriggeredCount = 0;
      var telemetrySyncFailedCount = 0;
      var secondarySensorTimeoutCount = 0;
      var doorOpenCount = 0;

      for (final entry in entries) {
        if (prevEventTimestamp != null) {
          final gap = entry.timestamp.difference(prevEventTimestamp).inSeconds;
          if (gap > rawEventGapMaxSeconds) {
            rawEventGapMaxSeconds = gap;
          }
        }
        prevEventTimestamp = entry.timestamp;

        switch (entry.type) {
          case _LogEventType.tempReading:
            currentTemperature = entry.numericValue ?? currentTemperature;
            tempReadingCount++;
            minTemp = minTemp < currentTemperature ? minTemp : currentTemperature;
            maxTemp = maxTemp > currentTemperature ? maxTemp : currentTemperature;

            if (prevTempTimestamp != null) {
              final gap = entry.timestamp.difference(prevTempTimestamp).inSeconds;
              if (gap > temperatureGapMaxSeconds) {
                temperatureGapMaxSeconds = gap;
              }
              if (gap > 30) {
                temperatureGapsOver30Seconds++;
              }
              if (gap > 90) {
                temperatureGapsOver90Seconds++;
              }
            }
            prevTempTimestamp = entry.timestamp;

            if (currentTemperature > sampleDevice.tempMaxOk ||
                currentTemperature < sampleDevice.tempMinOk) {
              overLimitCount++;
              firstOverLimitAt ??= entry.timestamp;
              currentExcursionStart ??= entry.timestamp;
            } else if (currentExcursionStart != null) {
              excursions.add(
                _TemperatureExcursion(
                  startedAt: currentExcursionStart,
                  endedAt: entry.timestamp,
                ),
              );
              currentExcursionStart = null;
            }
          case _LogEventType.batteryLevel:
            final value = entry.numericValue ?? currentBattery.toDouble();
            currentBattery = value.round();
            minBattery = minBattery < value ? minBattery : value;
            maxBattery = maxBattery > value ? maxBattery : value;
          case _LogEventType.fanSpeed:
            currentFanRpm = (entry.numericValue ?? currentFanRpm.toDouble()).round();
          case _LogEventType.humidity:
            currentHumidity =
                (entry.numericValue ?? currentHumidity.toDouble()).round();
          case _LogEventType.voltage:
            currentVoltage = entry.numericValue ?? currentVoltage;
          case _LogEventType.doorOpen:
            doorOpen = true;
            doorOpenCount++;
            doorOpenTimestamps.add(entry.timestamp);
          case _LogEventType.doorClose:
            doorOpen = false;
          case _LogEventType.sensorTimeout:
            if (entry.payload == 'SECONDARY_SENSOR') {
              sensorSecondaryActive = false;
              secondarySensorTimeoutCount++;
            } else {
              sensorPrimaryActive = false;
            }
          case _LogEventType.telemetrySyncFailed:
            online = false;
            telemetrySyncFailedCount++;
          case _LogEventType.tempWarning:
            tempWarningCount++;
          case _LogEventType.alarmTriggered:
            alarmTriggeredCount++;
            alarmTimestamps.add(entry.timestamp);
          case _LogEventType.deviceStart:
          case _LogEventType.coolingRecoveryStart:
            // Informational only.
        }

        if (entry.type != _LogEventType.telemetrySyncFailed) {
          online = true;
        }

        final baseSnapshot = TelemetrySnapshot(
          temperatureC: currentTemperature,
          batteryPercent: currentBattery,
          fanRpm: currentFanRpm,
          humidityPercent: currentHumidity,
          voltage: currentVoltage,
          sensorPrimaryActive: sensorPrimaryActive,
          sensorSecondaryActive: sensorSecondaryActive,
          doorOpen: doorOpen,
          online: online,
          alarmsActive: alarmsActive,
          activeAlert: AlertType.none,
          recentEvents: List.unmodifiable(recentEvents),
          recordedAt: entry.timestamp,
        );

        final recentEvent = _eventFromEntry(entry);
        if (recentEvent != null) {
          recentEvents.add(recentEvent);
          if (recentEvents.length > 6) {
            recentEvents.removeAt(0);
          }
        }

        final notification = _notificationFromEntry(entry);
        if (notification != null) {
          _notifications.add(notification);
        }

        final alert = baseSnapshot
            .copyWith(recentEvents: List.unmodifiable(recentEvents))
            .deriveAlert(sampleDevice);
        alarmsActive = alert == AlertType.none && entry.type != _LogEventType.alarmTriggered
            ? 0
            : 1;

        final resolvedSnapshot = baseSnapshot.copyWith(
          alarmsActive: alarmsActive,
          activeAlert: alert,
          recentEvents: List.unmodifiable(recentEvents),
        );

        if (entry.type == _LogEventType.tempReading) {
          _temperatureHistory.add(
            TemperaturePoint(
              timestamp: entry.timestamp,
              temperatureC: currentTemperature,
            ),
          );
          _history.add(resolvedSnapshot);
        }

        _current = resolvedSnapshot;
      }

      if (currentExcursionStart != null && prevTempTimestamp != null) {
        excursions.add(
          _TemperatureExcursion(
            startedAt: currentExcursionStart,
            endedAt: prevTempTimestamp,
          ),
        );
      }

      if (minTemp == double.infinity) {
        minTemp = sampleDevice.tempMinOk;
      }
      if (maxTemp == double.negativeInfinity) {
        maxTemp = sampleDevice.tempMinOk;
      }
      if (minBattery == double.infinity) {
        minBattery = currentBattery.toDouble();
      }
      if (maxBattery == double.negativeInfinity) {
        maxBattery = currentBattery.toDouble();
      }

      final maxDoorOpensPerHour = _maxDoorOpensPerHour(doorOpenTimestamps);

      _metrics = SessionMetrics(
        firstTimestamp: firstTimestamp,
        lastTimestamp: lastTimestamp,
        totalLines: entries.length,
        tempReadingCount: tempReadingCount,
        tempWarningCount: tempWarningCount,
        alarmTriggeredCount: alarmTriggeredCount,
        telemetrySyncFailedCount: telemetrySyncFailedCount,
        secondarySensorTimeoutCount: secondarySensorTimeoutCount,
        doorOpenCount: doorOpenCount,
        maxDoorOpensPerHour: maxDoorOpensPerHour,
        rawEventGapMaxSeconds: rawEventGapMaxSeconds,
        temperatureGapMaxSeconds: temperatureGapMaxSeconds,
        temperatureGapsOver30Seconds: temperatureGapsOver30Seconds,
        temperatureGapsOver90Seconds: temperatureGapsOver90Seconds,
        minTemperature: minTemp,
        maxTemperature: maxTemp,
        minBattery: minBattery,
        maxBattery: maxBattery,
        firstOverLimitAt: firstOverLimitAt,
        overLimitTemperatureCount: overLimitCount,
      );

      _buildTransports();
      _buildComplianceChecks(excursions, alarmTimestamps);

      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _isLoaded = true;
      _controller.add(_current);
    } catch (error) {
      _loadError = error;
      _current = _emptySnapshot();
      _controller.add(_current);
      rethrow;
    }
  }

  void _buildTransports() {
    final sessionDuration = _metrics.duration;
    final now = DateTime.now();
    const source = RouteLeg(
      city: 'Log local',
      facility: 'medical_device_logs_1000.txt',
    );
    const target = RouteLeg(
      city: 'Standard',
      facility: 'MED-THERM-2026',
    );

    sampleTransport = Transport(
      id: 'active-poc-session',
      deviceId: sampleDevice.id,
      transporterId: sampleTransporter.id,
      from: source,
      to: target,
      startedAt: now.subtract(sessionDuration),
    );

    pastTransports = [
      Transport(
        id: 'archived-poc-session',
        deviceId: sampleDevice.id,
        transporterId: sampleTransporter.id,
        from: source,
        to: target,
        startedAt: now.subtract(const Duration(days: 1, hours: 3)),
        endedAt: now.subtract(const Duration(days: 1, hours: 3))
            .add(sessionDuration),
      ),
    ];
  }

  void _buildComplianceChecks(
    List<_TemperatureExcursion> excursions,
    List<DateTime> alarmTimestamps,
  ) {
    final cumulativeExcursion = excursions.fold<Duration>(
      Duration.zero,
      (sum, excursion) => sum + excursion.duration,
    );
    final longestExcursion = excursions.fold<Duration>(
      Duration.zero,
      (longest, excursion) =>
          excursion.duration > longest ? excursion.duration : longest,
    );
    final hasAlarmAfterLongExcursion = excursions
        .where((excursion) => excursion.duration >= const Duration(minutes: 2))
        .every(
          (excursion) => alarmTimestamps.any(
            (alarmTimestamp) =>
                !alarmTimestamp.isBefore(
                  excursion.startedAt.add(const Duration(minutes: 2)),
                ),
          ),
        );

    _complianceChecks.addAll([
      ComplianceCheck(
        id: 'REG-TEMP-1',
        title: 'Temperatura intre 2C si 8C',
        state: _metrics.overLimitTemperatureCount == 0
            ? ComplianceState.compliant
            : ComplianceState.violation,
        detail: _metrics.overLimitTemperatureCount == 0
            ? 'Toate citirile de temperatura raman in intervalul admis.'
            : '${_metrics.overLimitTemperatureCount} citiri depasesc limita. '
                'Maximul observat este ${_metrics.maxTemperature.toStringAsFixed(1)}C.',
      ),
      ComplianceCheck(
        id: 'REG-TEMP-2',
        title: 'Excursii termice <= 5 minute si <= 10 minute / 24h',
        state: longestExcursion > const Duration(minutes: 5) ||
                cumulativeExcursion > const Duration(minutes: 10)
            ? ComplianceState.violation
            : ComplianceState.compliant,
        detail: excursions.isEmpty
            ? 'Nu exista excursii termice in citirile disponibile.'
            : 'Cea mai lunga excursie dureaza '
                '${_formatDuration(longestExcursion)}; durata cumulata este '
                '${_formatDuration(cumulativeExcursion)}.',
      ),
      const ComplianceCheck(
        id: 'REG-TEMP-3',
        title: 'Stabilizare <= 3 minute dupa deschiderea usii',
        state: ComplianceState.insufficientData,
        detail:
            'Logul include evenimente de usa si recovery, dar nu ofera destule '
            'perechi explicite pentru a demonstra stabilizarea corecta.',
      ),
      ComplianceCheck(
        id: 'REG-TEMP-4',
        title: 'Sampling temperatura <= 30 secunde',
        state: _metrics.temperatureGapsOver30Seconds == 0
            ? ComplianceState.compliant
            : ComplianceState.violation,
        detail: _metrics.temperatureGapsOver30Seconds == 0
            ? 'Nu exista gap-uri intre citiri mai mari de 30 secunde.'
            : '${_metrics.temperatureGapsOver30Seconds} gap-uri depasesc 30s. '
                'Maximul observat este ${_metrics.temperatureGapMaxSeconds}s.',
      ),
      ComplianceCheck(
        id: 'REG-SENS-1',
        title: 'Redundanta senzor obligatorie',
        state: _metrics.secondarySensorTimeoutCount == 0
            ? ComplianceState.compliant
            : ComplianceState.violation,
        detail: _metrics.secondarySensorTimeoutCount == 0
            ? 'Nu exista timeout-uri pentru senzorul secundar.'
            : '${_metrics.secondarySensorTimeoutCount} timeout-uri pentru '
                'senzorul secundar compromit redundanta.',
      ),
      const ComplianceCheck(
        id: 'REG-SENS-3',
        title: 'Acord intre senzori |T1-T2| <= 0.5C',
        state: ComplianceState.insufficientData,
        detail:
            'Fisierul nu contine valori separate pentru senzorul primar si cel secundar.',
      ),
      ComplianceCheck(
        id: 'REG-ALARM-1',
        title: 'Alarma dupa >= 2 minute de excursie termica',
        state: excursions.any(
                  (excursion) => excursion.duration >= const Duration(minutes: 2),
                ) &&
                hasAlarmAfterLongExcursion
            ? ComplianceState.compliant
            : ComplianceState.insufficientData,
        detail: hasAlarmAfterLongExcursion
            ? 'Excursiile termice mai lungi de 2 minute au alarme asociate in log.'
            : 'Logul nu permite corelarea completa intre excursie si momentul exact al alarmei.',
      ),
      const ComplianceCheck(
        id: 'REG-ALARM-2',
        title: 'Notificare livrata in <= 10 secunde',
        state: ComplianceState.insufficientData,
        detail:
            'Logul nu include timestamp separat pentru livrarea notificarii mobile.',
      ),
      const ComplianceCheck(
        id: 'REG-DATA-1',
        title: 'Audit log imutabil',
        state: ComplianceState.compliant,
        detail:
            'In PoC, fisierul este consumat local in regim read-only; aplicatia nu modifica logul.',
      ),
      ComplianceCheck(
        id: 'REG-DATA-2',
        title: 'Gap telemetrie <= 90 secunde',
        state: _metrics.rawEventGapMaxSeconds <= 90
            ? ComplianceState.compliant
            : ComplianceState.violation,
        detail: 'Fluxul brut de evenimente are un gap maxim de '
            '${_metrics.rawEventGapMaxSeconds}s. '
            '${_metrics.telemetrySyncFailedCount} evenimente indica sync esuat.',
      ),
      const ComplianceCheck(
        id: 'REG-DATA-3',
        title: 'Retentie locala >= 72 ore',
        state: ComplianceState.insufficientData,
        detail:
            'Setul de date incarcat acopera o singura sesiune, nu demonstrarea retentiei pe 72 de ore.',
      ),
      const ComplianceCheck(
        id: 'REG-POWER-1',
        title: 'Autonomie baterie >= 4 ore',
        state: ComplianceState.insufficientData,
        detail:
            'Logul arata trendul bateriei, dar nu include un test complet de descarcare controlata.',
      ),
      ComplianceCheck(
        id: 'REG-OPS-2',
        title: 'Avertisment la > 10 deschideri usa / ora',
        state: _metrics.maxDoorOpensPerHour > 10
            ? ComplianceState.violation
            : ComplianceState.compliant,
        detail: 'Numarul maxim observat este ${_metrics.maxDoorOpensPerHour} '
            'deschideri intr-o fereastra de o ora.',
      ),
    ]);
  }

  Future<String> _readLog() async {
    try {
      return await rootBundle.loadString(_logAssetPath);
    } catch (_) {
      return _fallbackLog;
    }
  }

  List<_LogEntry> _parseEntries(String rawLog) {
    final entries = <_LogEntry>[];
    for (final rawLine in rawLog.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      final match = RegExp(
        r'^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) ([A-Z_]+)(?: (.*))?$',
      ).firstMatch(line);
      if (match == null) continue;

      final timestamp = DateTime.parse(
        match.group(1)!.replaceFirst(' ', 'T'),
      );
      final eventName = match.group(2)!;
      final payload = match.group(3)?.trim();

      entries.add(
        _LogEntry(
          timestamp: timestamp,
          type: _eventTypeFromName(eventName),
          rawName: eventName,
          payload: payload,
          numericValue: _numericValueFromPayload(payload),
        ),
      );
    }

    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return entries;
  }

  _LogEventType _eventTypeFromName(String rawName) {
    switch (rawName) {
      case 'TEMP_READING':
        return _LogEventType.tempReading;
      case 'BATTERY_LEVEL':
        return _LogEventType.batteryLevel;
      case 'FAN_SPEED':
        return _LogEventType.fanSpeed;
      case 'HUMIDITY':
        return _LogEventType.humidity;
      case 'VOLTAGE':
        return _LogEventType.voltage;
      case 'DOOR_OPEN':
        return _LogEventType.doorOpen;
      case 'DOOR_CLOSE':
        return _LogEventType.doorClose;
      case 'SENSOR_TIMEOUT':
        return _LogEventType.sensorTimeout;
      case 'TELEMETRY_SYNC_FAILED':
        return _LogEventType.telemetrySyncFailed;
      case 'TEMP_WARNING':
        return _LogEventType.tempWarning;
      case 'ALARM_TRIGGERED':
        return _LogEventType.alarmTriggered;
      case 'DEVICE_START':
        return _LogEventType.deviceStart;
      case 'COOLING_RECOVERY_START':
        return _LogEventType.coolingRecoveryStart;
      default:
        return _LogEventType.deviceStart;
    }
  }

  double? _numericValueFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    final match = RegExp(r'(-?\d+(?:\.\d+)?)').firstMatch(payload);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }

  TelemetryEvent? _eventFromEntry(_LogEntry entry) {
    switch (entry.type) {
      case _LogEventType.alarmTriggered:
        return TelemetryEvent(
          label: 'Alarma declansata',
          icon: 'alarm',
          timestamp: entry.timestamp,
        );
      case _LogEventType.tempWarning:
        return TelemetryEvent(
          label: 'Temperatura aproape de limita',
          icon: 'thermostat',
          timestamp: entry.timestamp,
        );
      case _LogEventType.sensorTimeout:
        return TelemetryEvent(
          label: 'Timeout senzor secundar',
          icon: 'sensors',
          timestamp: entry.timestamp,
        );
      case _LogEventType.telemetrySyncFailed:
        return TelemetryEvent(
          label: 'Sincronizare telemetrie esuata',
          icon: 'sync_problem',
          timestamp: entry.timestamp,
        );
      case _LogEventType.doorOpen:
        return TelemetryEvent(
          label: 'Usa deschisa',
          icon: 'door_open',
          timestamp: entry.timestamp,
        );
      case _LogEventType.doorClose:
        return TelemetryEvent(
          label: 'Usa inchisa',
          icon: 'door_back',
          timestamp: entry.timestamp,
        );
      case _LogEventType.coolingRecoveryStart:
        return TelemetryEvent(
          label: 'Recuperare racire pornita',
          icon: 'ac_unit',
          timestamp: entry.timestamp,
        );
      case _LogEventType.deviceStart:
        return TelemetryEvent(
          label: 'Pornire dispozitiv',
          icon: 'power',
          timestamp: entry.timestamp,
        );
      case _LogEventType.tempReading:
      case _LogEventType.batteryLevel:
      case _LogEventType.fanSpeed:
      case _LogEventType.humidity:
      case _LogEventType.voltage:
        return null;
    }
  }

  AppNotification? _notificationFromEntry(_LogEntry entry) {
    switch (entry.type) {
      case _LogEventType.alarmTriggered:
        return AppNotification(
          title: 'Alarma activa',
          message:
              'Eveniment de alarma detectat in log la ${_clock(entry.timestamp)}.',
          timestamp: entry.timestamp,
          severity: NotificationSeverity.critical,
        );
      case _LogEventType.tempWarning:
        return AppNotification(
          title: 'Temperatura aproape de limita',
          message:
              'Logul semnaleaza TEMP_WARNING la ${_clock(entry.timestamp)}.',
          timestamp: entry.timestamp,
          severity: NotificationSeverity.warning,
        );
      case _LogEventType.sensorTimeout:
        return AppNotification(
          title: 'Senzor secundar indisponibil',
          message:
              'Evenimentul ${entry.rawName} ${entry.payload ?? ''} afecteaza redundanta.',
          timestamp: entry.timestamp,
          severity: NotificationSeverity.warning,
        );
      case _LogEventType.telemetrySyncFailed:
        return AppNotification(
          title: 'Sincronizare esuata',
          message: 'Telemetria nu s-a sincronizat la ${_clock(entry.timestamp)}.',
          timestamp: entry.timestamp,
          severity: NotificationSeverity.warning,
        );
      case _LogEventType.tempReading:
      case _LogEventType.batteryLevel:
      case _LogEventType.fanSpeed:
      case _LogEventType.humidity:
      case _LogEventType.voltage:
      case _LogEventType.doorOpen:
      case _LogEventType.doorClose:
      case _LogEventType.deviceStart:
      case _LogEventType.coolingRecoveryStart:
        return null;
    }
  }

  int _maxDoorOpensPerHour(List<DateTime> timestamps) {
    var maxCount = 0;
    for (final start in timestamps) {
      final end = start.add(const Duration(hours: 1));
      final count = timestamps
          .where((timestamp) => !timestamp.isBefore(start) && timestamp.isBefore(end))
          .length;
      if (count > maxCount) {
        maxCount = count;
      }
    }
    return maxCount;
  }

  String _clock(DateTime timestamp) {
    final hh = timestamp.hour.toString().padLeft(2, '0');
    final mm = timestamp.minute.toString().padLeft(2, '0');
    final ss = timestamp.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes == 0) {
      return '${duration.inSeconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  TelemetrySnapshot _emptySnapshot() {
    final now = DateTime.now();
    return TelemetrySnapshot(
      temperatureC: sampleDevice.tempMinOk,
      batteryPercent: 100,
      fanRpm: 0,
      humidityPercent: 0,
      voltage: 0,
      sensorPrimaryActive: true,
      sensorSecondaryActive: true,
      doorOpen: false,
      online: true,
      alarmsActive: 0,
      activeAlert: AlertType.none,
      recordedAt: now,
      recentEvents: [
        TelemetryEvent(
          label: 'Astept incarcare log PoC',
          icon: 'power',
          timestamp: now,
        ),
      ],
    );
  }

  SessionMetrics _emptyMetrics() {
    final now = DateTime.now();
    return SessionMetrics(
      firstTimestamp: now,
      lastTimestamp: now,
      totalLines: 0,
      tempReadingCount: 0,
      tempWarningCount: 0,
      alarmTriggeredCount: 0,
      telemetrySyncFailedCount: 0,
      secondarySensorTimeoutCount: 0,
      doorOpenCount: 0,
      maxDoorOpensPerHour: 0,
      rawEventGapMaxSeconds: 0,
      temperatureGapMaxSeconds: 0,
      temperatureGapsOver30Seconds: 0,
      temperatureGapsOver90Seconds: 0,
      minTemperature: sampleDevice.tempMinOk,
      maxTemperature: sampleDevice.tempMaxOk,
      minBattery: 100,
      maxBattery: 100,
      firstOverLimitAt: null,
      overLimitTemperatureCount: 0,
    );
  }

  void dispose() {
    _controller.close();
  }
}

enum _LogEventType {
  tempReading,
  batteryLevel,
  fanSpeed,
  humidity,
  voltage,
  doorOpen,
  doorClose,
  sensorTimeout,
  telemetrySyncFailed,
  tempWarning,
  alarmTriggered,
  deviceStart,
  coolingRecoveryStart,
}

class _LogEntry {
  const _LogEntry({
    required this.timestamp,
    required this.type,
    required this.rawName,
    required this.payload,
    required this.numericValue,
  });

  final DateTime timestamp;
  final _LogEventType type;
  final String rawName;
  final String? payload;
  final double? numericValue;
}

class _TemperatureExcursion {
  const _TemperatureExcursion({
    required this.startedAt,
    required this.endedAt,
  });

  final DateTime startedAt;
  final DateTime endedAt;

  Duration get duration => endedAt.difference(startedAt);
}

const String _fallbackLog = '''
2026-05-14 14:00:00 ALARM_TRIGGERED
2026-05-14 14:00:10 TEMP_READING 4.3C
2026-05-14 14:00:20 FAN_SPEED 2029RPM
2026-05-14 14:00:30 TELEMETRY_SYNC_FAILED
2026-05-14 14:00:40 ALARM_TRIGGERED
2026-05-14 14:00:50 DEVICE_START
2026-05-14 14:01:00 VOLTAGE 12.26V
2026-05-14 14:01:10 TEMP_READING 4.7C
2026-05-14 14:01:20 DOOR_CLOSE
2026-05-14 14:01:30 COOLING_RECOVERY_START
''';
