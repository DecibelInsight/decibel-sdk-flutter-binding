import 'package:flutter/material.dart';

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _sendScreenView(PageRoute<dynamic> route) {
    var screenName = route.settings.name ?? "no name";
    print('screenName $screenName');
    // do something with it, ie. send it to your analytics service collector
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint("did Push");
    if (route is PageRoute) {
      _sendScreenView(route);
    } else {
      debugPrint("not a PageRoute");
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    debugPrint("didReplace");

    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    } else {
      debugPrint("not a PageRoute");
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    debugPrint("didPop");
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    } else {
      debugPrint("not a PageRoute");
    }
  }
}
