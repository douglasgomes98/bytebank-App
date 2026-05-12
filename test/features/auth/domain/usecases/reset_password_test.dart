import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/core/error/failure.dart';
import 'package:bytebank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bytebank_app/features/auth/domain/usecases/reset_password.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late ResetPassword useCase;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = ResetPassword(mockRepo);
  });

  test('returns Right<Unit> when email is valid', () async {
    when(() => mockRepo.resetPassword(any()))
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase('valid@test.com');

    expect(result.isRight(), true);
  });

  test('returns Left<AuthFailure> when email not found', () async {
    when(() => mockRepo.resetPassword(any()))
        .thenAnswer((_) async => Left(AuthFailure('user-not-found')));

    final result = await useCase('notfound@test.com');

    expect(result.isLeft(), true);
  });
}
