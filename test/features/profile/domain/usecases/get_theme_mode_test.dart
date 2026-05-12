import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/features/profile/domain/entities/app_theme_mode.dart';
import 'package:bytebank_app/features/profile/domain/repositories/theme_repository.dart';
import 'package:bytebank_app/features/profile/domain/usecases/get_theme_mode.dart';

class MockThemeRepository extends Mock implements ThemeRepository {}

void main() {
  late MockThemeRepository mockRepo;
  late GetThemeMode useCase;

  setUp(() {
    mockRepo = MockThemeRepository();
    useCase = GetThemeMode(mockRepo);
  });

  test('returns Right<AppThemeMode> from repository', () async {
    when(() => mockRepo.getThemeMode())
        .thenAnswer((_) async => const Right(AppThemeMode.dark));

    final result = await useCase.call();

    expect(result.isRight(), true);
    expect(result.getOrElse((_) => AppThemeMode.system), AppThemeMode.dark);
  });
}
