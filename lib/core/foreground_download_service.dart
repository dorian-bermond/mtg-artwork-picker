import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// Runs in a background isolate — keeps the Android foreground service alive
// while the actual download runs on the main isolate.
class _NoOpTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}
  @override
  void onRepeatEvent(DateTime timestamp) {}
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}

@pragma('vm:entry-point')
void _noOpCallback() {
  FlutterForegroundTask.setTaskHandler(_NoOpTaskHandler());
}

class ForegroundDownloadService {
  ForegroundDownloadService._();

  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'mtg_download_channel',
        channelName: 'Artwork Download',
        channelDescription: 'Runs while artworks are being downloaded.',
        onlyAlertOnce: true,
        playSound: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> start({String text = 'Starting…'}) async {
    try {
      final permission = await FlutterForegroundTask.checkNotificationPermission();
      if (permission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'Downloading Artworks',
        notificationText: text,
        callback: _noOpCallback,
      );
    } catch (_) {}
  }

  static Future<void> update(String text) async {
    try {
      await FlutterForegroundTask.updateService(notificationText: text);
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await FlutterForegroundTask.stopService();
    } catch (_) {}
  }
}
