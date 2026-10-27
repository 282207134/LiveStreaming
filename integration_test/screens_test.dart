import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:live_streaming/app.dart';
import 'package:live_streaming/core/app_controller.dart';
import 'package:live_streaming/core/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'capture all design states in light and dark on Android',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = await AppController.load();
      await tester.pumpWidget(
        UtubeeApp(controller: state, initialPage: AppPage.discover),
      );
      await tester.pumpAndSettle();
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      const selection = String.fromEnvironment('SCREENSHOT_PAGES');
      final pages = AppPage.values
          .where(
            (p) => selection.isEmpty || selection.split(',').contains(p.name),
          )
          .toList();
      for (final dark in [false, true]) {
        state.update(() => state.darkMode = dark);
        await tester.pumpAndSettle();
        for (final page in pages) {
          navigatorKey.currentState!.pushNamedAndRemoveUntil(
            page.name,
            (_) => false,
          );
          if (page == AppPage.splash) {
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 450));
          } else {
            await tester.pumpAndSettle();
          }
          await tester.pump(const Duration(milliseconds: 150));
          expect(
            tester.takeException(),
            isNull,
            reason: '${page.name} dark=$dark',
          );
          final theme = dark ? 'dark' : 'light';
          final bytes = await binding.takeScreenshot('$theme/${page.name}');
          final file = File(
            '${Directory.systemTemp.path}/utubee_screenshots/$theme/${page.name}.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes, flush: true);
          // Transfer screenshots from app cache with adb; avoid a huge JSON
          // report containing every PNG byte as an integer.
          binding.reportData!['screenshots'] = <dynamic>[];
        }
      }
      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        AppPage.discover.name,
        (_) => false,
      );
      await tester.pumpAndSettle();
      binding.reportData ??= {};
      binding.reportData!['screenCount'] = pages.length * 2;
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}
