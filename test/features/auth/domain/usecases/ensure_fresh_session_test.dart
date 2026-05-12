import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bytebank_app/features/auth/domain/usecases/ensure_fresh_session.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late EnsureFreshSession useCase;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = EnsureFreshSession(mockRepo);
  });

  test('returns Right<Unit> when session refresh succeeds', () async {
    when(() => mockRepo.ensureFreshSession())
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase();

    expect(result.isRight(), true);
    verify(() => mockRepo.ensureFreshSession()).called(1);
  });
}
