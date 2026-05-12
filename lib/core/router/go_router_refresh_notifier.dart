import 'package:flutter/foundation.dart';

class GoRouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
