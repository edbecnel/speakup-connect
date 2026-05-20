## Android Build Warning: KGP Plugin Compatibility

### Warning
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP):
flutter_image_compress_common, image_picker_android, shared_preferences_android

### Status
- All three plugins are already at their latest published versions (no updates available).
- This is an upstream issue — the plugin authors have not yet migrated to AGP 9.0 built-in Kotlin.
- Currently NON-BLOCKING due to `android.builtInKotlin=false` in android/gradle.properties.

### Current Workaround (android/gradle.properties)
android.builtInKotlin=false
android.newDsl=false

### Resolution
Wait for plugin authors to release compatible versions:
- image_picker_android — first-party Flutter/Google plugin
- shared_preferences_android — first-party Flutter/Google plugin
- flutter_image_compress_common — community plugin (file/watch issue on GitHub)

Once compatible versions are released, run `flutter pub upgrade`, then
set `android.builtInKotlin=true` in gradle.properties.

### Date Noted
2026-05-20