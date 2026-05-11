import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/features/profile/domain/entities/app_theme_mode.dart';
import 'package:bytebank_app/features/profile/providers/profile_providers.dart';

part 'theme_notifier.g.dart';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  FutureOr<ThemeMode> build() async {
    final result = await ref.read(getThemeModeProvider).call();
    return result.fold((_) => ThemeMode.system, _toMaterialMode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await ref.read(setThemeModeProvider).call(_toAppMode(mode));
    state = AsyncData(mode);
  }

  ThemeMode _toMaterialMode(AppThemeMode mode) => switch (mode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };

  AppThemeMode _toAppMode(ThemeMode mode) => switch (mode) {
        ThemeMode.system => AppThemeMode.system,
        ThemeMode.light => AppThemeMode.light,
        ThemeMode.dark => AppThemeMode.dark,
      };
}
