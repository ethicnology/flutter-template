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

/// Switches between top-level journeys. The caller owns the selected index and
/// builds only the active child; inactive journeys are not kept mounted.
class UiNavigation extends StatelessWidget {
  const UiNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.child,
    super.key,
  }) : assert(destinations.length >= 2, 'Navigation needs two destinations.');

  final List<UiDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: [
        for (final destination in destinations)
          NavigationDestination(
            icon: Icon(_glyph(destination.icon)),
            label: destination.label,
          ),
      ],
    ),
  );

  static IconData _glyph(UiIcon icon) => switch (icon) {
    UiIcon.compose => Icons.edit_outlined,
    UiIcon.review => Icons.list_alt_outlined,
  };
}
