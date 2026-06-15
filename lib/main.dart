import 'package:flutter/material.dart';
import 'package:funswap/app.dart';
import 'package:funswap/core/services/preferences_service.dart';
import 'package:funswap/injection_container.dart' as di; // di for dependency injection

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesService.init();
  await di.init();
  runApp(const FunSwapApp());
}
