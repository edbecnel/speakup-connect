import 'package:flutter/material.dart';

/// App bar title that ellipsizes instead of overlapping the leading back
/// button or trailing actions when translations are long.
class AppBarTitleText extends StatelessWidget {
  const AppBarTitleText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }
}
