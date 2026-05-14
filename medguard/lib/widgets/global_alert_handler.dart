import 'package:flutter/material.dart';

import '../data/mock_repository.dart';
import '../models/models.dart';
import '../screens/alert_screen.dart';

/// Global alert handler wrapping the main app router.
///
/// Shows the AlertScreen modal when a critical alert is triggered and not yet
/// acknowledged. This ensures alerts are shown regardless of which screen the
/// user is on.
class GlobalAlertHandler extends StatefulWidget {
  const GlobalAlertHandler({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<GlobalAlertHandler> createState() => _GlobalAlertHandlerState();
}

class _GlobalAlertHandlerState extends State<GlobalAlertHandler> {
  @override
  Widget build(BuildContext context) {
    final repo = MockRepository.instance;

    return StreamBuilder<TelemetrySnapshot>(
      stream: repo.telemetryStream,
      initialData: repo.current,
      builder: (context, snapshot) {
        final telemetry = snapshot.data!;
        final currentAlert =
            telemetry.activeAlert != AlertType.none ? telemetry.activeAlert : null;
        final acknowledgedAlert = repo.acknowledgedAlert;
        final showAlertModal =
            currentAlert != null && currentAlert != acknowledgedAlert;

        // Show alert modal as a full-screen overlay if unacknowledged
        if (showAlertModal) {
          return Stack(
            children: [
              widget.child,
              Positioned.fill(
                child: AlertScreen(
                  alert: currentAlert,
                  telemetry: telemetry,
                  onDismiss: () {
                    repo.acknowledgeAlert(currentAlert);
                  },
                ),
              ),
            ],
          );
        }

        return widget.child;
      },
    );
  }
}
