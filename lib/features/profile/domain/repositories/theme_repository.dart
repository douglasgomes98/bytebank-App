import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/app_theme_mode.dart';

/// Contrato do repositório que armazena a preferência de tema do usuário.
///
/// A implementação concreta utiliza `shared_preferences`, conforme já
/// existente, mas o domínio fica desacoplado do pacote.
abstract class ThemeRepository {
  /// Lê o [AppThemeMode] persistido. Retorna [AppThemeMode.system] quando
  /// nenhum valor foi gravado anteriormente.
  Future<Either<Failure, AppThemeMode>> getThemeMode();

  /// Persiste o [mode] selecionado pelo usuário.
  Future<Either<Failure, Unit>> setThemeMode(AppThemeMode mode);
}
