import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/app_theme_mode.dart';
import '../repositories/theme_repository.dart';

/// Caso de uso que persiste a preferência de tema escolhida pelo usuário.
class SetThemeMode {
  final ThemeRepository _repository;

  /// Cria um caso de uso ligado a [_repository].
  const SetThemeMode(this._repository);

  /// Salva [mode] como a preferência de tema atual.
  Future<Either<Failure, Unit>> call(AppThemeMode mode) =>
      _repository.setThemeMode(mode);
}
