import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/account.dart';

AppLifecycleState actuaApplState;

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  }) {
    actuaApplState = AppLifecycleState.resumed;
  }

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    actuaApplState = state;
    print(actuaApplState);
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack();

          await stopRetroshare();
        }
        break;
    }
  }
}
