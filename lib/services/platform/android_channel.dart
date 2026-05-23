import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/utils/countdown_utils.dart';
import '../../data/models/task_model.dart';
import 'method_channel_names.dart';

class AndroidChannel {
  AndroidChannel._();

  static const MethodChannel _channel = MethodChannel(
    MethodChannelNames.android,
  );

  static Future<void> syncWidget(ClinicTask task) {
    return _invoke('syncWidget', _taskPayload(task));
  }

  static Future<void> scheduleReminders(ClinicTask task) {
    return _invoke('scheduleReminders', _taskPayload(task));
  }

  static Future<void> cancelReminders() {
    return _invoke('cancelReminders');
  }

  static Future<void> startStrictFocus(ClinicTask task) {
    return _invoke('startStrictFocus', _taskPayload(task));
  }

  static Future<void> stopStrictFocus() {
    return _invoke('stopStrictFocus');
  }

  static Future<void> openOverlayPermission() {
    return _invoke('openOverlayPermission');
  }

  static Future<bool> pinTaskWidget() {
    return _invokeBool('pinWidget', {'type': 'task'});
  }

  static Future<bool> pinFocusWidget() {
    return _invokeBool('pinWidget', {'type': 'focus'});
  }

  static Future<bool> pinPunishmentWidget() {
    return _invokeBool('pinWidget', {'type': 'punishment'});
  }

  static Future<void> _invoke(
    String method, [
    Map<String, Object?>? args,
  ]) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>(method, args);
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    } catch (_) {
      return;
    }
  }

  static Future<bool> _invokeBool(
    String method, [
    Map<String, Object?>? args,
  ]) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      return await _channel.invokeMethod<bool>(method, args) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static Map<String, Object?> _taskPayload(ClinicTask task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'startLabel': task.startLabel,
      'deadlineLabel': task.deadlineLabel,
      'remainingSeconds': task.remainingSeconds,
      'remainingLabel': formatClock(task.remainingSeconds),
      'graceSeconds': task.graceSeconds,
      'status': task.status.name,
      'blockExit': task.blockExit,
    };
  }
}
