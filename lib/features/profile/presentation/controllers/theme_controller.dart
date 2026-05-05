import 'package:flutter/material.dart';

import '../../domain/entities/app_theme_mode.dart';
import '../../domain/usecases/get_theme_mode.dart';
import '../../domain/usecases/set_theme_mode.dart';

/// Controller (camada de apresentação) que controla o tema aplicado.
///
/// Reúne os casos de uso [GetThemeMode] e [SetThemeMode] e expõe um
/// [ThemeMode] do Material consumido pelo `MaterialApp`.
class ThemeController extends ChangeNotifier {
  final GetThemeMode _getThemeMode;
  final SetThemeMode _setThemeMode;

  ThemeMode _themeMode = ThemeMode.system;

  /// Cria um [ThemeController]. A leitura inicial da preferência
  /// persistida é disparada automaticamente.
  ThemeController({
    required GetThemeMode getThemeMode,
    required SetThemeMode setThemeMode,
  })  : _getThemeMode = getThemeMode,
        _setThemeMode = setThemeMode {
    _load();
  }

  /// Modo de tema corrente, pronto para ser passado ao `MaterialApp`.
  ThemeMode get themeMode => _themeMode;

  /// `true` quando o tema escuro está ativo.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Lê a preferência persistida e atualiza o estado interno.
  Future<void> _load() async {
    final result = await _getThemeMode();
    result.fold(
      (_) {
        _themeMode = ThemeMode.system;
        notifyListeners();
      },
      (appMode) {
        _themeMode = _toMaterialMode(appMode);
        notifyListeners();
      },
    );
  }

  /// Define [mode] como o tema corrente e persiste a escolha.
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _setThemeMode(_toAppMode(mode));
  }

  /// Alterna entre claro e escuro, replicando o comportamento do
  /// `ThemeProvider.toggleTheme` original.
  Future<void> toggleTheme() {
    return setTheme(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  /// Converte [AppThemeMode] (domínio) para [ThemeMode] (Material).
  ThemeMode _toMaterialMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// Converte [ThemeMode] (Material) para [AppThemeMode] (domínio).
  AppThemeMode _toAppMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return AppThemeMode.system;
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
    }
  }
}
