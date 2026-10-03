import 'package:flutter/material.dart';

import 'ui_tokens.dart';

/// A scrollable page with safe insets and a readable maximum content width.
/// Children must use intrinsic height rather than vertical Expanded widgets.
class UiPage extends StatelessWidget {
  const UiPage({
    required this.title,
    required this.child,
    this.actions,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: UiTokens.maxContentWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UiTokens.pagePadding),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    ),
  );
}

class UiColumn extends StatelessWidget {
  const UiColumn({required this.children, super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    spacing: UiTokens.spacing,
    children: children,
  );
}

class UiTextField extends StatelessWidget {
  const UiTextField({
    required this.label,
    required this.onChanged,
    this.controller,
    this.errorText,
    super.key,
  });

  final String label;
  final ValueChanged<String> onChanged;

  /// The caller owns and disposes an explicitly supplied controller.
  final TextEditingController? controller;
  final String? errorText;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(labelText: label, errorText: errorText),
  );
}

class UiButton extends StatelessWidget {
  const UiButton({
    required this.label,
    required this.onPressed,
    this.busy = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: busy ? null : onPressed,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: UiTokens.compactSpacing),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: UiTokens.compactSpacing,
        runSpacing: UiTokens.smallSpacing,
        children: [
          if (busy)
            const SizedBox.square(
              dimension: UiTokens.progressSize,
              child: CircularProgressIndicator(
                strokeWidth: UiTokens.progressStrokeWidth,
              ),
            ),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

/// The meaning of a piece of text; the kit maps it to the theme's type scale.
enum UiTextRole { title, body, caption }

/// Themed text. Features choose the role, never a text style.
class UiText extends StatelessWidget {
  const UiText(this.text, {this.role = UiTextRole.body, super.key});
  final String text;
  final UiTextRole role;

  @override
  Widget build(BuildContext context) {
    final scale = Theme.of(context).textTheme;
    return Text(
      text,
      style: switch (role) {
        UiTextRole.title => scale.titleMedium,
        UiTextRole.body => scale.bodyMedium,
        UiTextRole.caption => scale.bodySmall,
      },
    );
  }
}

/// Receives a safe, already localized message, never a raw exception.
class UiError extends StatelessWidget {
  const UiError(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(UiTokens.cornerRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UiTokens.spacing),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      ),
    ),
  );
}

class UiLoading extends StatelessWidget {
  const UiLoading({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(UiTokens.pagePadding),
      child: CircularProgressIndicator(),
    ),
  );
}

/// An intrinsic list for short collections inside [UiPage].
/// Large datasets need a dedicated virtualized component.
class UiList extends StatelessWidget {
  const UiList({required this.children, super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: children,
  );
}

/// Places the action beside the content when it fits, or below it otherwise.
class UiListTile extends StatelessWidget {
  const UiListTile({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: UiTokens.compactSpacing),
    child: OverflowBar(
      alignment: MainAxisAlignment.spaceBetween,
      spacing: UiTokens.compactSpacing,
      overflowSpacing: UiTokens.compactSpacing,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) Text(subtitle!),
          ],
        ),
        ?trailing,
      ],
    ),
  );
}

class UiEmpty extends StatelessWidget {
  const UiEmpty(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: UiTokens.emptyPadding),
    child: Text(message, textAlign: TextAlign.center),
  );
}
