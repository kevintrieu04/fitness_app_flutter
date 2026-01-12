// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(routerNotifier)
final routerProvider = RouterNotifierProvider._();

final class RouterNotifierProvider
    extends $FunctionalProvider<RouterNotifier, RouterNotifier, RouterNotifier>
    with $Provider<RouterNotifier> {
  RouterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerNotifierHash();

  @$internal
  @override
  $ProviderElement<RouterNotifier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RouterNotifier create(Ref ref) {
    return routerNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouterNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouterNotifier>(value),
    );
  }
}

String _$routerNotifierHash() => r'dcf71aaf6412855459e08b6a61106caff408a995';
