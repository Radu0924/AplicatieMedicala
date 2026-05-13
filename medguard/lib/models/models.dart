import '../widgets/status_badge.dart';

/// Lightweight app models for the local PoC.
///
/// The mobile app reads a bundled log file and derives its UI state from that
/// historical telemetry stream and the MED-THERM-2026 rules.

class Transporter {
  const Transporter({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
}

class Device {
  const Device({
    required this.id,
    required this.code,
    required this.tempMinOk,
    required this.tempMaxOk,
    required this.tempWarningThreshold,
    required this.dispatchPhone,
  });

  final String id;
  final String code;
  final double tempMinOk;
  final double tempMaxOk;
  final double tempWarningThreshold;
  final String dispatchPhone;
}

class RouteLeg {
  const RouteLeg({required this.city, required this.facility});

  final String city;
  final String facility;
}

class Transport {
  const Transport({
    required this.id,
    required this.deviceId,
    required this.transporterId,
    required this.from,
    required this.to,
    required this.startedAt,
    this.endedAt,
  });

  final String id;
  final String deviceId;
  final String transporterId;
  final RouteLeg from;
  final RouteLeg to;
  final DateTime startedAt;
  final DateTime? endedAt;

  Duration get elapsed => DateTime.now().difference(startedAt);

  bool get isActive => endedAt == null;
}

enum AlertType {
  temperatureHigh,
  temperatureLow,
  sensorPrimaryFail,
  sensorSecondaryFail,
  none,
}

extension AlertTypeUi on AlertType {
  String get romanianMessage {
    switch (this) {
      case AlertType.temperatureHigh:
        return 'Temperatura a depasit limita maxima admisa.\nVerifica imediat scenariul PoC.';
      case AlertType.temperatureLow:
        return 'Temperatura a scazut sub limita minima admisa.\nVerifica imediat scenariul PoC.';
      case AlertType.sensorPrimaryFail:
        return 'Senzorul principal nu mai functioneaza.\nDatele PoC sunt compromise.';
      case AlertType.sensorSecondaryFail:
        return 'Senzorul secundar nu mai functioneaza.\nRedundanta nu mai este conforma.';
      case AlertType.none:
        return '';
    }
  }

  bool get isCritical {
    switch (this) {
      case AlertType.temperatureHigh:
      case AlertType.temperatureLow:
      case AlertType.sensorPrimaryFail:
        return true;
      case AlertType.sensorSecondaryFail:
      case AlertType.none:
        return false;
    }
  }
}

enum NotificationSeverity { critical, warning, info }

extension NotificationSeverityUi on NotificationSeverity {
  String get romanianLabel {
    switch (this) {
      case NotificationSeverity.critical:
        return 'CRITICA';
      case NotificationSeverity.warning:
        return 'ATENTIE';
      case NotificationSeverity.info:
        return 'INFO';
    }
  }

  DeviceStatus get status {
    switch (this) {
      case NotificationSeverity.critical:
        return DeviceStatus.critical;
      case NotificationSeverity.warning:
        return DeviceStatus.warning;
      case NotificationSeverity.info:
        return DeviceStatus.ok;
    }
  }
}

class AppNotification {
  const AppNotification({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.severity,
    this.isRead = false,
  });

  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationSeverity severity;
  final bool isRead;
}

enum ComplianceState { compliant, violation, insufficientData }

extension ComplianceStateUi on ComplianceState {
  String get romanianLabel {
    switch (this) {
      case ComplianceState.compliant:
        return 'CONFORM';
      case ComplianceState.violation:
        return 'INCALCARE';
      case ComplianceState.insufficientData:
        return 'DATE INSUFICIENTE';
    }
  }

  DeviceStatus get status {
    switch (this) {
      case ComplianceState.compliant:
        return DeviceStatus.ok;
      case ComplianceState.violation:
        return DeviceStatus.critical;
      case ComplianceState.insufficientData:
        return DeviceStatus.warning;
    }
  }
}

class ComplianceCheck {
  const ComplianceCheck({
    required this.id,
    required this.title,
    required this.state,
    required this.detail,
  });

  final String id;
  final String title;
  final ComplianceState state;
  final String detail;
}

class ComplianceOverview {
  const ComplianceOverview({
    required this.total,
    required this.compliant,
    required this.violations,
    required this.insufficientData,
  });

  final int total;
  final int compliant;
  final int violations;
  final int insufficientData;
}

class SessionMetrics {
  const SessionMetrics({
    required this.firstTimestamp,
    required this.lastTimestamp,
    required this.totalLines,
    required this.tempReadingCount,
    required this.tempWarningCount,
    required this.alarmTriggeredCount,
    required this.telemetrySyncFailedCount,
    required this.secondarySensorTimeoutCount,
    required this.doorOpenCount,
    required this.maxDoorOpensPerHour,
    required this.rawEventGapMaxSeconds,
    required this.temperatureGapMaxSeconds,
    required this.temperatureGapsOver30Seconds,
    required this.temperatureGapsOver90Seconds,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minBattery,
    required this.maxBattery,
    required this.firstOverLimitAt,
    required this.overLimitTemperatureCount,
  });

  final DateTime firstTimestamp;
  final DateTime lastTimestamp;
  final int totalLines;
  final int tempReadingCount;
  final int tempWarningCount;
  final int alarmTriggeredCount;
  final int telemetrySyncFailedCount;
  final int secondarySensorTimeoutCount;
  final int doorOpenCount;
  final int maxDoorOpensPerHour;
  final int rawEventGapMaxSeconds;
  final int temperatureGapMaxSeconds;
  final int temperatureGapsOver30Seconds;
  final int temperatureGapsOver90Seconds;
  final double minTemperature;
  final double maxTemperature;
  final double minBattery;
  final double maxBattery;
  final DateTime? firstOverLimitAt;
  final int overLimitTemperatureCount;

  Duration get duration => lastTimestamp.difference(firstTimestamp);
}

class TemperaturePoint {
  const TemperaturePoint({
    required this.timestamp,
    required this.temperatureC,
  });

  final DateTime timestamp;
  final double temperatureC;
}

class TelemetrySnapshot {
  const TelemetrySnapshot({
    required this.temperatureC,
    required this.batteryPercent,
    required this.fanRpm,
    required this.humidityPercent,
    required this.voltage,
    required this.sensorPrimaryActive,
    required this.sensorSecondaryActive,
    required this.doorOpen,
    required this.online,
    required this.alarmsActive,
    required this.activeAlert,
    required this.recentEvents,
    required this.recordedAt,
  });

  final double temperatureC;
  final int batteryPercent;
  final int fanRpm;
  final int humidityPercent;
  final double voltage;
  final bool sensorPrimaryActive;
  final bool sensorSecondaryActive;
  final bool doorOpen;
  final bool online;
  final int alarmsActive;
  final AlertType activeAlert;
  final List<TelemetryEvent> recentEvents;
  final DateTime recordedAt;

  DeviceStatus statusFor(Device device) {
    if (!sensorPrimaryActive) return DeviceStatus.critical;
    if (temperatureC > device.tempMaxOk || temperatureC < device.tempMinOk) {
      return DeviceStatus.critical;
    }
    if (alarmsActive > 0) return DeviceStatus.critical;
    if (temperatureC >= device.tempWarningThreshold ||
        !sensorSecondaryActive ||
        !online) {
      return DeviceStatus.warning;
    }
    return DeviceStatus.ok;
  }

  AlertType deriveAlert(Device device) {
    if (!sensorPrimaryActive) return AlertType.sensorPrimaryFail;
    if (temperatureC > device.tempMaxOk) return AlertType.temperatureHigh;
    if (temperatureC < device.tempMinOk) return AlertType.temperatureLow;
    if (!sensorSecondaryActive) return AlertType.sensorSecondaryFail;
    return AlertType.none;
  }

  TelemetrySnapshot copyWith({
    double? temperatureC,
    int? batteryPercent,
    int? fanRpm,
    int? humidityPercent,
    double? voltage,
    bool? sensorPrimaryActive,
    bool? sensorSecondaryActive,
    bool? doorOpen,
    bool? online,
    int? alarmsActive,
    AlertType? activeAlert,
    List<TelemetryEvent>? recentEvents,
    DateTime? recordedAt,
  }) {
    return TelemetrySnapshot(
      temperatureC: temperatureC ?? this.temperatureC,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      fanRpm: fanRpm ?? this.fanRpm,
      humidityPercent: humidityPercent ?? this.humidityPercent,
      voltage: voltage ?? this.voltage,
      sensorPrimaryActive: sensorPrimaryActive ?? this.sensorPrimaryActive,
      sensorSecondaryActive: sensorSecondaryActive ?? this.sensorSecondaryActive,
      doorOpen: doorOpen ?? this.doorOpen,
      online: online ?? this.online,
      alarmsActive: alarmsActive ?? this.alarmsActive,
      activeAlert: activeAlert ?? this.activeAlert,
      recentEvents: recentEvents ?? this.recentEvents,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}

class TelemetryEvent {
  const TelemetryEvent({
    required this.label,
    required this.icon,
    required this.timestamp,
  });

  final String label;
  final String icon;
  final DateTime timestamp;
}
