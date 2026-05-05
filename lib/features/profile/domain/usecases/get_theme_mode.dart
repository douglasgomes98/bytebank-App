import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/app_theme_mode.dart';
import '../repositories/theme_repository.dart';

/// Caso de uso que lê a preferência de tema persistida.
class GetThemeMode {
  final ThemeRepository _repository;

  /// Cria um caso de uso ligado a [_repository].
  const GetThemeMode(this._repository);

  /// Retorna o [AppThemeMode] persistido para o usuário.
  Future<Either<Failure, AppThemeMode>> call() => _repository.getThemeMode();
}
