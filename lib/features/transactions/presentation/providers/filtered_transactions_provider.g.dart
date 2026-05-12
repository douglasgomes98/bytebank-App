// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filtered_transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$debouncedSearchQueryHash() =>
    r'919c8b2e0e0666f3b5ebbca9ed31c2881e71ab5b';

/// See also [debouncedSearchQuery].
@ProviderFor(debouncedSearchQuery)
final debouncedSearchQueryProvider = AutoDisposeStreamProvider<String>.internal(
  debouncedSearchQuery,
  name: r'debouncedSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$debouncedSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DebouncedSearchQueryRef = AutoDisposeStreamProviderRef<String>;
String _$filteredTransactionsHash() =>
    r'3e17cd098f5814fd994f67d7bf9d41ab23af8d02';

/// See also [filteredTransactions].
@ProviderFor(filteredTransactions)
final filteredTransactionsProvider =
    AutoDisposeProvider<List<TransactionEntity>>.internal(
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
    AutoDisposeProviderRef<List<TransactionEntity>>;
String _$transactionSearchQueryHash() =>
    r'50d44c9bbc111da4f6535358d9d4e9f3abdc5a06';

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
