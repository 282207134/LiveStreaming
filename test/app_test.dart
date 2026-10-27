import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_streaming/app.dart';
import 'package:live_streaming/core/app_controller.dart';
import 'package:live_streaming/core/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Montserrat')
      ..addFont(rootBundle.load('assets/fonts/Montserrat.ttf'));
    await loader.load();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'preferences preserve profile, saved streams, following and theme',
    () async {
      final state = await AppController.load();
      state.update(() {
        state.darkMode = true;
        state.username = 'new_player';
      });
      state.toggleSaved('dota');
      state.toggleFollow('T1 Faker');
      state.recordWatch('counter');
      await state.flush();
      final restored = await AppController.load();
      expect(restored.darkMode, isTrue);
      expect(restored.username, 'new_player');
      expect(restored.saved, contains('dota'));
      expect(restored.followed, contains('T1 Faker'));
      expect(restored.history.first, 'counter');
    },
  );

  testWidgets('all Pixso routes render on a narrow phone in both themes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = await AppController.load();
    await tester.pumpWidget(
      UtubeeApp(controller: state, initialPage: AppPage.discover),
    );
    for (final dark in [false, true]) {
      state.update(() => state.darkMode = dark);
      for (final page in AppPage.values.where((p) => p != AppPage.splash)) {
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
          page.name,
          (_) => false,
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${page.name} dark=$dark',
        );
      }
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'sign in validation, stream chat, follow and profile changes work',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final state = await AppController.load();
      await tester.pumpWidget(
        UtubeeApp(controller: state, initialPage: AppPage.signIn),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('auth_password')), 'x');
      await tester.tap(find.byKey(const ValueKey('auth_submit')));
      await tester.pumpAndSettle();
      expect(find.text('Use at least 8 characters'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('auth_password')),
        'demo12345',
      );
      await tester.tap(find.byKey(const ValueKey('auth_submit')));
      await tester.pumpAndSettle();
      expect(state.signedIn, isTrue);
      expect(find.text('Discover'), findsOneWidget);

      navigatorKey.currentState!.pushNamed(AppPage.watchControls.name);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save_stream')));
      await tester.pump();
      expect(state.saved.contains('featured'), isFalse);
      await tester.enterText(
        find.byKey(const ValueKey('chat_input')),
        'Great game!',
      );
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();
      expect(state.sentMessages, contains('Great game!'));

      navigatorKey.currentState!.pushNamed(AppPage.channelPast.name);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('follow_channel')));
      await tester.tap(find.byKey(const ValueKey('follow_channel')));
      await tester.pumpAndSettle();
      expect(state.followed, contains('T1 Faker'));

      navigatorKey.currentState!.pushNamed(AppPage.editProfile.name);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('profile_name')),
        'new_player',
      );
      await tester.tap(find.byKey(const ValueKey('save_profile')));
      await tester.pumpAndSettle();
      expect(state.username, 'new_player');
      expect(tester.takeException(), isNull);
      await state.flush();
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('chat remains usable with keyboard on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final state = await AppController.load();
    await tester.pumpWidget(
      UtubeeApp(controller: state, initialPage: AppPage.watchEmoji),
    );
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('chat_input')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'past-video search shows an empty state for a game with no videos',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final state = await AppController.load();
      await tester.pumpWidget(
        UtubeeApp(controller: state, initialPage: AppPage.searchVideos),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('search_input')),
        'FORTNITE',
      );
      await tester.pumpAndSettle();
      expect(find.text('No results found'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
