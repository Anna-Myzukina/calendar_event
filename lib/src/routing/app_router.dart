import 'package:calendar_event/src/add_event_page.dart';
import 'package:calendar_event/src/device_calendar_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum AppRoute {
  home,
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
          path: '/',
          name: AppRoute.home.name,
          builder: (context, state) => const DeviceCalenderPage(),
          // builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'addEventPage/:defaultCalendarId',
              name: "addEventPage",
              builder: (context, state) {
                final id = state.params["defaultCalendarId"];
                return AddEventPage(
                  defaultCalenderId: id!,
                );
              },
            ),
          ]),
    ],
  );
});
