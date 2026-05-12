import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/features/profile/domain/entities/app_theme_mode.dart';
import 'package:bytebank_app/features/profile/domain/repositories/theme_repository.dart';
import 'package:bytebank_app/features/profile/domain/usecases/set_theme_mode.dart';

class MockThemeRepository extends Mock implements ThemeRepository {}

void main() {
  late MockThemeRepository mockRepo;
  late SetThemeMode useCase;

  setUpAll(() {
    registerFallbackValue(AppThemeMode.system);
  });

  setUp(() {
    mockRepo = MockThemeRepository();
    useCase = SetThemeMode(mockRepo);
  });

  test('calls repository and returns Right<Unit>', () async {
    when(() => mockRepo.setThemeMode(any()))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase.call(AppThemeMode.dark);

    expect(result.isRight(), true);
    verify(() => mockRepo.setThemeMode(AppThemeMode.dark)).called(1);
  });
}
