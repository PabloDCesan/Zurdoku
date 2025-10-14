import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavState {
  final int selectedIndex;
  final List<String> routes;

  const BottomNavState({
    this.selectedIndex = 0,
    this.routes = const ['/main-menu', '/achievements', '/about', '/exit'],
  });

  BottomNavState copyWith({
    int? selectedIndex,
    List<String>? routes,
  }) {
    return BottomNavState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      routes: routes ?? this.routes,
    );
  }
}

class BottomNavNotifier extends Notifier<BottomNavState> {
  @override
  BottomNavState build() => const BottomNavState();

  void setSelectedIndex(int index) {
    if (index >= 0 && index < state.routes.length) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  String getCurrentRoute() {
    return state.routes[state.selectedIndex];
  }

  void navigateToRoute(String route) {
    final index = state.routes.indexOf(route);
    if (index != -1) {
      setSelectedIndex(index);
    }
  }
}

final bottomNavProvider = NotifierProvider<BottomNavNotifier, BottomNavState>(() {
  return BottomNavNotifier();
});
