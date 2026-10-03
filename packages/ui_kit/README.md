# UI kit

Owns application themes and the shared visual vocabulary. Features import `package:ui_kit/ui_kit.dart` for rendered controls and `package:flutter/widgets.dart` for structural primitives such as `StatefulWidget`; the kit does not re-export Flutter's widget types. Material and Cupertino implementations belong here, not in features. This package has no business, storage, or feature dependencies.

## Usage

```dart
UiKitApp(
  title: 'Example',
  home: UiPage(
    title: 'Capture',
    child: UiColumn(
      children: [
        const UiText('Create an item.'),
        UiButton(label: 'Create', onPressed: createItem),
      ],
    ),
  ),
);
```

Use `UiKitApp` once at the application boundary. Features supply translated strings and their localization delegates; the kit adds Flutter's built-in localization delegates. `UiError` only accepts a safe user-facing message. It never logs or translates an exception. `UiThemes.light` and `UiThemes.dark` are the same themes consumed by Widgetbook.

## Layout and state

`UiTokens` exposes the shared spacing, padding, corner radius, progress dimensions and maximum content width. Change these decisions centrally instead of introducing local magic numbers in features. The input theme and feedback components share the corner-radius token.

`UiPage` is the only screen structure: title bar, optional actions, scrollable content, and the navigation slot filled by an enclosing `UiNavigation`. It handles safe insets, scrolling, 24 logical pixels of padding and a 720-pixel maximum outer content width. Its child must have intrinsic height; do not put vertical `Expanded` widgets inside it. `UiList` is intended for short collections, not large datasets requiring virtualization. Text scaling is inherited without clamping. `UiButton` disables its action while busy and retains its label.

`UiNavigation` is an inherited scope, not a container: it contributes the bottom navigation bar to every `UiPage` below it, so pages stay unaware of navigation and there is one scaffold per screen. The caller owns the selected index, builds only the active child, and gives each `UiDestination` a label and a semantic `UiIcon` that the kit maps to a glyph. `UiText` takes a `UiTextRole`, title, body or caption, mapped to the theme's type scale; features never choose a text style.

`UiListTile` constrains content and trailing actions to the available width. When they do not fit side by side, the action moves below the content and its text can wrap; neither text scaling nor content is clipped to force a row.

Extend the kit rather than bypassing it: a feature that needs a component the kit lacks adds it here, with a Widgetbook case and a widget test, in the same change. A component must carry a product decision; a bare wrapper around a Material widget does not qualify. Components have no application state or resources. A caller that supplies a `TextEditingController` owns its disposal. Do not use this package for domain operations or error classification. Add missing visual patterns here instead of importing Material widgets into a feature.

## Verification

From this directory, run `flutter test`. Tests cover theme application, page width, disabled/busy interactions, increased text scale, and narrow layouts with long trailing actions. Review visual states in [the Widgetbook example](example/README.md); visual inspection supplements rather than replaces behavioral tests. The example is a separate application package that consumes this kit; production code does not depend on Widgetbook.
