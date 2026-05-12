import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytebank_app/features/auth/domain/entities/app_user.dart';
import 'package:bytebank_app/features/auth/providers/auth_providers.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
Stream<AppUser?> authStateStream(AuthStateStreamRef ref) {
  final useCase = ref.watch(watchAuthStateProvider);
  return useCase();
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AppUser?> build() async {
    final sub = ref.listen<AsyncValue<AppUser?>>(
      authStateStreamProvider,
      (_, next) => state = next,
    );
    ref.onDispose(sub.close);
    return ref.read(authStateStreamProvider.future);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signInProvider)
        .call(email: email, password: password);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(signUpProvider)
        .call(name: name, email: email, password: password);
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (user) => state = AsyncData(user),
    );
  }

  Future<void> signOut() async {
    await ref.read(signOutProvider).call();
    state = const AsyncData(null);
  }

  Future<void> resetPassword(String email) async {
    await ref.read(resetPasswordProvider).call(email);
  }
}
