import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_controller.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'features/auth/auth_pages.dart';
import 'features/browse/browse_pages.dart';
import 'features/channel/channel_pages.dart';
import 'features/profile/profile_pages.dart';
import 'features/search/search_page.dart';
import 'features/social/social_pages.dart';
import 'features/watch/watch_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class UtubeeApp extends StatelessWidget {
  const UtubeeApp({
    super.key,
    required this.controller,
    this.initialPage = AppPage.splash,
  });
  final AppController controller;
  final AppPage initialPage;
  @override
  Widget build(BuildContext context) => AppScope(
    controller: controller,
    child: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => MaterialApp(
        title: 'Utubee',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: appTheme(Brightness.light),
        darkTheme: appTheme(Brightness.dark),
        themeMode: controller.darkMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: initialPage.name,
        onGenerateRoute: (settings) {
          final page = AppPage.values.firstWhere(
            (p) => p.name == settings.name,
            orElse: () => initialPage,
          );
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => _screen(page, settings.arguments),
          );
        },
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value:
              (controller.darkMode
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark)
                  .copyWith(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: controller.darkMode
                        ? Colors.black
                        : Colors.white,
                  ),
          child: LayoutBuilder(
            builder: (context, box) => ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: child!,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _screen(AppPage page, Object? arguments) => switch (page) {
  AppPage.splash ||
  AppPage.onboarding1 ||
  AppPage.onboarding2 ||
  AppPage.onboarding3 ||
  AppPage.congratulations => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: EntryPage(page),
  ),
  AppPage.welcome => EntryPage(page),
  AppPage.signIn || AppPage.signUp || AppPage.signUpError => AuthPage(page),
  AppPage.forgotPhone ||
  AppPage.verifyCode ||
  AppPage.newPassword => RecoveryPage(page),
  AppPage.chooseGames => const ChooseGamesPage(),
  AppPage.discover => const DiscoverPage(),
  AppPage.discoverMini => const DiscoverPage(mini: true),
  AppPage.following => const DiscoverPage(following: true),
  AppPage.browseCategories => const BrowsePage(),
  AppPage.browseLive => const BrowsePage(live: true),
  AppPage.categoryLive ||
  AppPage.categoryPast ||
  AppPage.categoryClips => CategoryPage(page: page, gameId: arguments),
  AppPage.filter => const FilterPage(),
  AppPage.tags => const FilterPage(tagsOnly: true),
  AppPage.searchTop ||
  AppPage.searchChannels ||
  AppPage.searchCategories ||
  AppPage.searchVideos => SearchPage(page),
  AppPage.watch ||
  AppPage.watchControls ||
  AppPage.watchSticker ||
  AppPage.watchGif ||
  AppPage.watchEmoji => WatchPage(page, streamId: arguments),
  AppPage.channelPast ||
  AppPage.channelClips ||
  AppPage.channelOverview ||
  AppPage.channelGallery => ChannelPage(page),
  AppPage.followers => const ConnectionsPage(),
  AppPage.channelFollowing => const ConnectionsPage(following: true),
  AppPage.profileSaved => const ProfilePage(),
  AppPage.profileHistory => const ProfilePage(history: true),
  AppPage.settings => const SettingsPage(),
  AppPage.editProfile => const EditProfilePage(),
  AppPage.notifications => const NotificationsPage(),
  AppPage.messages => SocialPage(recipient: arguments),
  AppPage.friends => const SocialPage(friends: true),
};
