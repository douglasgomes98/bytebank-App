import 'dart:async';
import 'package:flutter/foundation.dart';

class GoRouterRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshNotifier(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
