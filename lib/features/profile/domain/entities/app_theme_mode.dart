/// Representação de domínio do modo de tema selecionado pelo usuário.
///
/// Mantida em Dart puro (sem `package:flutter`) para que a camada de
/// domínio não dependa do framework de UI. A camada de apresentação
/// converte este valor no `ThemeMode` do Material.
enum AppThemeMode {
  /// Segue a configuração do sistema operacional.
  system,

  /// Sempre claro.
  light,

  /// Sempre escuro.
  dark,
}

/// Conversões seguras a partir de [String] para [AppThemeMode].
extension AppThemeModeParsing on AppThemeMode {
  /// Converte o `name` persistido em [AppThemeMode], retornando
  /// [AppThemeMode.system] como fallback.
  static AppThemeMode fromName(String? value) {
    if (value == null) return AppThemeMode.system;
    return AppThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}
