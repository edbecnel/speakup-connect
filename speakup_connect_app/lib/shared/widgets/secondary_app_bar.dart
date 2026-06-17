import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/shared/widgets/app_bar_title_text.dart';

/// App bar for pushed screens with a back button.
///
/// Uses a compact [leadingWidth] and [titleSpacing] so long titles (including
/// translations) get more room before ellipsizing.
class SecondaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SecondaryAppBar({
    required this.title,
    this.actions,
    this.bottom,
    super.key,
  });

  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  static const double _leadingWidth = 48;
  static const double _titleSpacing = 4;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: BackButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(Routes.home);
          }
        },
      ),
      leadingWidth: _leadingWidth,
      titleSpacing: _titleSpacing,
      centerTitle: false,
      clipBehavior: Clip.hardEdge,
      title: AppBarTitleText(title),
      actions: actions,
      bottom: bottom,
    );
  }
}
