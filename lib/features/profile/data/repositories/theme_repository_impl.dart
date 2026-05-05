import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/preferences_data_source.dart';

/// Implementação concreta de [ThemeRepository].
///
/// Persiste a preferência via [PreferencesDataSource] e converte erros
/// de cache em [CacheFailure].
class ThemeRepositoryImpl implements ThemeRepository {
  final PreferencesDataSource _dataSource;

  /// Cria um [ThemeRepositoryImpl] ligado a [_dataSource].
  const ThemeRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, AppThemeMode>> getThemeMode() async {
    try {
      final raw = await _dataSource.readThemeMode();
      return Right(AppThemeModeParsing.fromName(raw));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> setThemeMode(AppThemeMode mode) async {
    try {
      await _dataSource.writeThemeMode(mode.name);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
