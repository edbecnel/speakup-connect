import 'package:speakup_connect/flavor_config.dart';
import 'package:speakup_connect/main_common.dart';

/// MONHS client build entry point (current pilot deployment).
///
/// Launcher name: "Speakup MONHS". For the generic app use
/// `main_standard.dart` instead.
void main() async {
  FlavorConfig.instance = FlavorConfig.monhs();
  await mainCommon();
}
