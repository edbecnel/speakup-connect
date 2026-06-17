import 'package:speakup_connect/flavor_config.dart';
import 'package:speakup_connect/main_common.dart';

/// Entry point for the standard Speakup Connect app store listing.
///
/// Build with native label "Speakup Connect" (see docs/CLIENT_BUILDS.md).
void main() async {
  FlavorConfig.instance = FlavorConfig.standard();
  await mainCommon();
}
