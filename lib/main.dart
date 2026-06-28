import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/foreground_download_service.dart';
import 'routing.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ForegroundDownloadService.init();
  runApp(ProviderScope(child: App(router: buildRouter())));
}
