import 'package:flutter/material.dart';

/// Root navigator for dialogs and sheets when the caller sits above [Overlay]
/// (e.g. [MaterialApp.builder] translation-mode banner).
final rootNavigatorKey = GlobalKey<NavigatorState>();
