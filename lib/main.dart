import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/app.dart';
import 'package:shiba/data/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LocalModelApp()));
  // Warm up the database in background to avoid blocking first frame on cold start.
  unawaited(() async {
    try {
      await DatabaseHelper.instance.database;
    } catch (_) {}
  }());
}
