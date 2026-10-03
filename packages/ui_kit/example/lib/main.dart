import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

void main() => runApp(const WidgetCatalog());

class WidgetCatalog extends StatelessWidget {
  const WidgetCatalog({super.key});

  @override
  Widget build(BuildContext context) => Widgetbook.material(
    directories: [
      WidgetbookComponent(
        name: 'Text',
        useCases: [
          WidgetbookUseCase(
            name: 'Roles',
            builder: (_) => _page(
              const UiColumn(
                children: [
                  UiText('A section title', role: UiTextRole.title),
                  UiText('Body text carries the main content.'),
                  UiText(
                    'A caption adds secondary detail.',
                    role: UiTextRole.caption,
                  ),
                ],
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Long content',
            builder: (_) => _page(
              const UiText(
                'Readable text adapts to the available width and respects '
                'the text size selected by the reader. This longer example '
                'helps review wrapping on narrow screens without truncation.',
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Buttons',
        useCases: [
          WidgetbookUseCase(
            name: 'Enabled',
            builder: (_) =>
                _page(UiButton(label: 'Continue', onPressed: () {})),
          ),
          WidgetbookUseCase(
            name: 'Disabled',
            builder: (_) =>
                _page(const UiButton(label: 'Continue', onPressed: null)),
          ),
          WidgetbookUseCase(
            name: 'Busy',
            builder: (_) =>
                _page(UiButton(label: 'Saving', onPressed: () {}, busy: true)),
          ),
          WidgetbookUseCase(
            name: 'Long label',
            builder: (_) => _page(
              UiButton(
                label: 'Confirm this action and continue to the next step',
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Input',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (_) =>
                _page(UiTextField(label: 'Title', onChanged: (_) {})),
          ),
          WidgetbookUseCase(
            name: 'Validation error',
            builder: (_) => _page(
              UiTextField(
                label: 'Title',
                errorText: 'Enter a title before continuing.',
                onChanged: (_) {},
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Feedback',
        useCases: [
          WidgetbookUseCase(
            name: 'Empty',
            builder: (_) => _page(const UiEmpty('No items yet.')),
          ),
          WidgetbookUseCase(
            name: 'Loading',
            builder: (_) => _page(const UiLoading()),
          ),
          WidgetbookUseCase(
            name: 'Recoverable error',
            builder: (_) => _page(
              UiColumn(
                children: [
                  const UiError(
                    'Changes could not be saved. Please try again.',
                  ),
                  UiButton(label: 'Try again', onPressed: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'List',
        useCases: [
          WidgetbookUseCase(
            name: 'Long trailing action',
            builder: (_) => _page(
              UiListTile(
                title: 'An item',
                subtitle: 'The action moves below when space is limited.',
                trailing: UiButton(
                  label: 'Review and confirm this item',
                  onPressed: () {},
                ),
              ),
            ),
          ),
          WidgetbookUseCase(
            name: 'Content',
            builder: (_) => _page(
              const UiList(
                children: [
                  UiListTile(
                    title: 'First item',
                    subtitle: 'Supporting detail',
                  ),
                  UiListTile(
                    title: 'A longer title that can wrap on narrow screens',
                    subtitle: 'Content remains readable at larger text scales.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Navigation',
        useCases: [
          WidgetbookUseCase(
            name: 'Two journeys',
            builder: (_) => UiNavigation(
              destinations: const [
                UiDestination(label: 'Capture', icon: UiIcon.compose),
                UiDestination(label: 'Review', icon: UiIcon.review),
              ],
              selectedIndex: 0,
              onSelected: (_) {},
              child: _page(const UiText('The selected journey renders here.')),
            ),
          ),
        ],
      ),
    ],
    addons: [
      ViewportAddon([
        Viewports.none,
        IosViewports.iPhone13,
        AndroidViewports.samsungGalaxyNote20,
        WindowsViewports.desktop,
      ]),
      MaterialThemeAddon(
        themes: [
          WidgetbookTheme(name: 'Light', data: UiThemes.light),
          WidgetbookTheme(name: 'Dark', data: UiThemes.dark),
        ],
      ),
      TextScaleAddon(),
      LocalizationAddon(
        locales: const [Locale('en'), Locale('fr')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
      ),
    ],
  );
}

Widget _page(Widget child) => UiPage(title: 'Component preview', child: child);
