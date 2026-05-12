import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/core/error/failure.dart';
import 'package:bytebank_app/features/auth/domain/entities/app_user.dart';
import 'package:bytebank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bytebank_app/features/auth/domain/usecases/sign_in.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late SignIn useCase;

  final tUser = AppUser(
    id: '1',
    name: 'Test',
    email: 'test@test.com',
    balance: 0.0,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = SignIn(mockRepo);
  });

  test('returns Right<AppUser> when credentials are valid', () async {
    when(() => mockRepo.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => Right(tUser));

    final result = await useCase(email: 'test@test.com', password: '123456');

    expect(result.isRight(), true);
    expect(result.getOrElse((_) => throw Exception()), tUser);
  });

  test('returns Left<AuthFailure> when credentials are invalid', () async {
    when(() => mockRepo.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => Left(AuthFailure('invalid-credentials')));

    final result = await useCase(email: 'test@test.com', password: 'wrong');

    expect(result.isLeft(), true);
  });
}
