import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bytebank_app/features/auth/domain/usecases/sign_out.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late SignOut useCase;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = SignOut(mockRepo);
  });

  test('calls repository signOut and returns Right<Unit>', () async {
    when(() => mockRepo.signOut())
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase();

    expect(result.isRight(), true);
    verify(() => mockRepo.signOut()).called(1);
  });
}
