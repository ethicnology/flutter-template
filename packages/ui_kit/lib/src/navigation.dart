import 'package:flutter/material.dart';

/// Semantic icons available to navigation destinations.
/// The kit chooses the platform glyph; callers choose the meaning.
enum UiIcon { compose, review }

/// A top-level journey reachable from the application navigation.
final class UiDestination {
  const UiDestination({required this.label, required this.icon});

  final String label;
  final UiIcon icon;
}

/// Contributes the navigation slot of every [UiPage] below it. The caller owns
/// the selected index and builds only the active journey; inactive journeys
/// are not kept mounted. Pages stay unaware of navigation, which keeps one
/// screen structure per page.
class UiNavigation extends InheritedWidget {
  const UiNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required super.child,
    super.key,
  }) : assert(destinations.length >= 2, 'Navigation needs two destinations.');

  final List<UiDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static UiNavigation? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UiNavigation>();

  @override
  bool updateShouldNotify(UiNavigation oldWidget) =>
      selectedIndex != oldWidget.selectedIndex ||
      destinations != oldWidget.destinations;

  Widget buildBar() => NavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: onSelected,
    destinations: [
      for (final destination in destinations)
        NavigationDestination(
          icon: Icon(_glyph(destination.icon)),
          label: destination.label,
        ),
    ],
  );

  static IconData _glyph(UiIcon icon) => switch (icon) {
    UiIcon.compose => Icons.edit_outlined,
    UiIcon.review => Icons.list_alt_outlined,
  };
}
