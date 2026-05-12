// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filtered_transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredTransactionsHash() =>
    r'5658a1c360afb410868d8d13ee3aaa60a6ddebce';

/// See also [filteredTransactions].
@ProviderFor(filteredTransactions)
final filteredTransactionsProvider =
    AutoDisposeStreamProvider<TransactionUiState>.internal(
      filteredTransactions,
      name: r'filteredTransactionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredTransactionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredTransactionsRef =
    AutoDisposeStreamProviderRef<TransactionUiState>;
String _$transactionSearchQueryHash() =>
    r'83776225972e0f1b8a02a9382858ff5a32aaea20';

/// See also [TransactionSearchQuery].
@ProviderFor(TransactionSearchQuery)
final transactionSearchQueryProvider =
    AutoDisposeNotifierProvider<TransactionSearchQuery, String>.internal(
      TransactionSearchQuery.new,
      name: r'transactionSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TransactionSearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
