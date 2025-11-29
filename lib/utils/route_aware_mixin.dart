import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Mixin that provides automatic data refresh when screen becomes visible
mixin RouteAwareRefresh<T extends StatefulWidget> on State<T>, RouteAware {
  bool _wasVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = GoRouterState.of(context);
    if (route != null) {
      final isVisible = ModalRoute.of(context)?.isCurrent ?? false;
      if (isVisible && !_wasVisible) {
        _wasVisible = true;
        onScreenVisible();
      } else if (!isVisible) {
        _wasVisible = false;
      }
    }
  }

  /// Override this method to refresh data when screen becomes visible
  void onScreenVisible() {}
}

