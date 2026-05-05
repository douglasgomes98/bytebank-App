import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';

/// Fonte de dados que encapsula leituras e escritas em
/// [SharedPreferences] relacionadas às preferências do perfil.
///
/// Atualmente persiste apenas a preferência de tema, mas pode ser
/// estendida no futuro para armazenar outras preferências de UI sem
/// impactar a camada de domínio.
class PreferencesDataSource {
  /// Lê a string persistida sob a chave [AppConstants.themeKey].
  Future<String?> readThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.themeKey);
    } catch (e) {
      throw CacheException('Erro ao ler preferências: $e');
    }
  }

  /// Persiste [value] sob a chave [AppConstants.themeKey].
  Future<void> writeThemeMode(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.themeKey, value);
    } catch (e) {
      throw CacheException('Erro ao gravar preferências: $e');
    }
  }
}
