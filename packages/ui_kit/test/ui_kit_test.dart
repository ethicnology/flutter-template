import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('application applies the requested production theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      const UiKitApp(
        title: 'Test',
        themeMode: ThemeMode.dark,
        home: UiPage(title: 'Page', child: UiText('Content')),
      ),
    );
    final context = tester.element(find.text('Content'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(Theme.of(context).colorScheme, UiThemes.dark.colorScheme);
  });

  testWidgets('wide pages constrain content and narrow pages fit', (
    tester,
  ) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());
    tester.view.devicePixelRatio = 1;
    const marker = Key('content');
    for (final width in [1200.0, 320.0]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(
        const UiKitApp(
          title: 'Test',
          home: UiPage(
            title: 'Page',
            child: SizedBox(key: marker, height: 10),
          ),
        ),
      );
      await tester.pump();
      expect(tester.getSize(find.byKey(marker)).width, width > 720 ? 672 : 272);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('busy and disabled buttons cannot invoke actions', (
    tester,
  ) async {
    var invocations = 0;
    await tester.pumpWidget(
      UiKitApp(
        title: 'Test',
        home: UiPage(
          title: 'Page',
          child: UiColumn(
            children: [
              const UiButton(label: 'Disabled', onPressed: null),
              UiButton(
                label: 'Busy',
                busy: true,
                onPressed: () => invocations++,
              ),
              UiButton(label: 'Enabled', onPressed: () => invocations++),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Disabled'));
    await tester.tap(find.text('Busy'));
    expect(invocations, 0);
    await tester.tap(find.text('Enabled'));
    expect(invocations, 1);
  });

  testWidgets('large text remains visible on a narrow scrollable page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UiKitApp(
        title: 'Test',
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: UiPage(
            title: 'Page',
            child: UiColumn(
              children: [
                const UiText('A long piece of content that wraps naturally.'),
                const UiError('Changes could not be saved. Please try again.'),
                UiButton(
                  label: 'Confirm this action and continue to the next step',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final text = tester.element(
      find.text('A long piece of content that wraps naturally.'),
    );
    expect(MediaQuery.textScalerOf(text).scale(14), 28);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('list item action fits a narrow page with large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(280, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var invocations = 0;
    const actionLabel = 'Review and confirm this item';

    await tester.pumpWidget(
      UiKitApp(
        title: 'Test',
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3)),
          child: UiPage(
            title: 'Page',
            child: UiListTile(
              title: 'An item',
              trailing: UiButton(
                label: actionLabel,
                onPressed: () => invocations++,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final tile = tester.getRect(find.byType(UiListTile));
    final action = tester.getRect(find.byType(UiButton));
    expect(action.left, greaterThanOrEqualTo(tile.left));
    expect(action.right, lessThanOrEqualTo(tile.right));
    expect(
      action.top,
      greaterThan(tester.getRect(find.text('An item')).bottom),
    );
    await tester.ensureVisible(find.text(actionLabel));
    await tester.tap(find.text(actionLabel));
    expect(invocations, 1);
  });

  testWidgets(
    'feedback, inputs and lists fit narrow widths at large text sizes',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final width in [280.0, 320.0]) {
        for (final scale in [1.0, 2.0, 3.0]) {
          tester.view.physicalSize = Size(width, 800);
          await tester.pumpWidget(
            UiKitApp(
              title: 'Test',
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: UiPage(
                  title: 'Page',
                  child: UiColumn(
                    children: [
                      const UiText('Long content wraps without truncation.'),
                      UiTextField(label: 'Title', onChanged: (_) {}),
                      const UiError('Please try again when you are ready.'),
                      UiButton(
                        label: 'Save these changes and continue',
                        busy: true,
                        onPressed: () {},
                      ),
                      const UiEmpty('No matching items are available yet.'),
                      const UiList(
                        children: [
                          UiListTile(
                            title: 'An item with a longer title',
                            subtitle: 'Supporting information also wraps.',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: 'Layout must fit width $width with text scale $scale.',
          );
        }
      }
    },
  );

  testWidgets('navigation reports the selected destination', (tester) async {
    final selected = <int>[];
    await tester.pumpWidget(
      UiKitApp(
        title: 'Test',
        home: UiNavigation(
          destinations: const [
            UiDestination(label: 'Capture', icon: UiIcon.compose),
            UiDestination(label: 'Review', icon: UiIcon.review),
          ],
          selectedIndex: 0,
          onSelected: selected.add,
          child: const UiPage(title: 'Page', child: UiText('Active')),
        ),
      ),
    );
    expect(find.text('Active'), findsOneWidget);
    await tester.tap(find.text('Review'));
    expect(selected, [1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('text roles follow the theme type scale', (tester) async {
    await tester.pumpWidget(
      const UiKitApp(
        title: 'Test',
        home: UiPage(
          title: 'Page',
          child: UiText('Heading', role: UiTextRole.title),
        ),
      ),
    );
    final context = tester.element(find.text('Heading'));
    expect(
      tester.widget<Text>(find.text('Heading')).style,
      Theme.of(context).textTheme.titleMedium,
    );
  });
}
