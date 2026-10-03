# Component catalog

An isolated Widgetbook 3.25.0 application for reviewing the production `ui_kit`. Use cases are registered manually: adding a component does not require running a generator. No persistence, network service, or feature startup is required.

This catalog lives under `packages/ui_kit/example` alongside its owning kit, but retains its own `pubspec.yaml` and the `widget_catalog` package identity. It depends on the kit, not the other way around. Shared primitives belong in the kit; feature-specific business compositions remain in their features.

After resolving the workspace, run `flutter run -d chrome` from this directory on a workstation with a browser session, or build the web target with `flutter build web`. The repository's verification commands remain the authoritative automated checks.

The catalog uses the kit's actual light and dark themes. Viewport, text scale and localization controls allow reviewing layout behavior. Preview labels deliberately stay English; changing the locale changes built-in Flutter localization, not these sample strings. Feature-owned translated screens must provide their own delegates and use cases when added.

Included cases cover standalone long text; enabled, disabled, busy and long-label buttons; normal and invalid text inputs; empty, loading and error feedback; a populated list; and a list item with a long trailing action. The shared page and column layouts compose these cases. This is a local review tool and does not configure cloud publishing or visual snapshot approval.

Addon APIs were checked against the official [theme](https://docs.widgetbook.io/addons/theme-addon), [viewport](https://docs.widgetbook.io/addons/viewport-addon), [text scale](https://docs.widgetbook.io/addons/text-scale-addon) and [localization](https://docs.widgetbook.io/addons/localization-addon) documentation. Viewport is the outermost addon so subsequent theme and text-scale settings apply inside it.
