import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/features/profile/data/datasources/preferences_data_source.dart';
import 'package:bytebank_app/features/profile/data/repositories/theme_repository_impl.dart';
import 'package:bytebank_app/features/profile/domain/repositories/theme_repository.dart';
import 'package:bytebank_app/features/profile/domain/usecases/get_theme_mode.dart';
import 'package:bytebank_app/features/profile/domain/usecases/set_theme_mode.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
PreferencesDataSource preferencesDataSource(PreferencesDataSourceRef ref) =>
    PreferencesDataSource();

@Riverpod(keepAlive: true)
ThemeRepository themeRepository(ThemeRepositoryRef ref) =>
    ThemeRepositoryImpl(ref.watch(preferencesDataSourceProvider));

@Riverpod(keepAlive: true)
GetThemeMode getThemeMode(GetThemeModeRef ref) =>
    GetThemeMode(ref.watch(themeRepositoryProvider));

@Riverpod(keepAlive: true)
SetThemeMode setThemeMode(SetThemeModeRef ref) =>
    SetThemeMode(ref.watch(themeRepositoryProvider));
