# 0002: Features compose a shared presentation kit

Status: Accepted for this template.

## Context

When each feature independently chooses widgets, themes, platform adaptation, and reusable accessibility behavior, product-wide changes require editing many unrelated journeys. A single shell containing all screen details creates the opposite coupling.

## Decision

`ui_kit` owns shared visual components, themes, adaptive behavior, reusable accessibility conventions, and the screen structure itself: `UiPage` is the only scaffold and navigation is a slot it fills from an enclosing `UiNavigation`. Features consume its public API and do not import Material or Cupertino directly. The kit is extended, never bypassed: a feature that needs a missing component adds it to the kit in the same change, with a Widgetbook case and a widget test. Each component carries a product decision; a bare wrapper around a Material widget does not qualify. Features own journey state, content, localized labels, and internal navigation. The shell connects feature entry points through application-level routing.

Develop and review shared component states in the separate Widgetbook application at `packages/ui_kit/example`. The application has its own pubspec and depends on the kit; the production kit never depends on its catalog. Keep the catalog independent of feature orchestration and persistent capability instances. Do not impose a state-management framework merely to standardize module structure.

## Consequences

Visual changes have an explicit owner and features can focus on user intent. Kit APIs must remain sufficient for real feature needs; do not compensate for missing primitives with duplicated local design systems. Feature-specific content and interaction accessibility still require feature-level review and testing.

## Verification

Import checks enforce the design-system boundary. Widget tests verify component behavior; feature tests verify meaningful composition and state transitions. Widgetbook supports visual review but does not prove native-platform behavior or whole-journey accessibility.

## References

Sources consulted 2026-10-02: [Flutter adaptive layout guidance](https://docs.flutter.dev/ui/adaptive-responsive/best-practices), [accessibility testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing), and [Widgetbook monorepo catalogs](https://docs.widgetbook.io/essentials/monorepo). Use the workspace's pinned Melos configuration; older catalog examples may still use `melos.yaml`. Test available width, enlarged text and meaningful interactions; a viewport preview is not a native accessibility test.
