import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebank_app/core/error/failure.dart';
import 'package:bytebank_app/features/auth/domain/entities/app_user.dart';
import 'package:bytebank_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bytebank_app/features/auth/domain/usecases/sign_up.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late SignUp useCase;

  final tUser = AppUser(
    id: '1',
    name: 'New User',
    email: 'new@test.com',
    balance: 0.0,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = SignUp(mockRepo);
  });

  test('returns Right<AppUser> on successful registration', () async {
    when(() => mockRepo.signUp(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => Right(tUser));

    final result = await useCase(
        name: 'New User', email: 'new@test.com', password: 'secure123');

    expect(result.isRight(), true);
  });

  test('returns Left<AuthFailure> when email already in use', () async {
    when(() => mockRepo.signUp(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer(
            (_) async => Left(AuthFailure('email-already-in-use')));

    final result = await useCase(
        name: 'New User', email: 'existing@test.com', password: 'secure123');

    expect(result.isLeft(), true);
  });
}
