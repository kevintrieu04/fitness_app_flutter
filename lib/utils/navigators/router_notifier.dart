import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/auth_viewmodel.dart';
part 'router_notifier.g.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    // We listen to the authViewModelProvider.
    // Whenever the state changes, we call notifyListeners().
    ref.listen(authViewModelProvider, (_, __) {
      notifyListeners();
    });
  }
}

// Provide the notifier
@riverpod
RouterNotifier routerNotifier(Ref ref) {
  return RouterNotifier(ref);
}