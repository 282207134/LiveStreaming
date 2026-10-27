import 'package:flutter/material.dart';

enum AppPage {
  splash('Splash', '1:94'),
  onboarding1('Onboarding - 1', '1:11'),
  onboarding2('Onboarding - 2', '44:1443'),
  onboarding3('Onboarding - 3', '50:1435'),
  welcome('Welcome', '50:1564'),
  signIn('Sign In', '37:136'),
  signUp('Sign Up', '51:279'),
  signUpError('Sign Up - Wrong Input', '51:350'),
  congratulations('Sign Up - Congratulation', '51:953'),
  forgotPhone('Forgot Password - Phone Number', '51:419'),
  verifyCode('Forgot Password - Verify Code', '51:547'),
  newPassword('Forgot Password - New Password', '51:729'),
  chooseGames('Choose Game', '37:848'),
  discover('Discover', '95:0'),
  discoverMini('Discover - Small Screen', '119:124'),
  following('Following', '156:678'),
  browseCategories('Browse - Categories', '172:453'),
  browseLive('Browse - Live Channel', '174:1304'),
  categoryLive('Categories - Live', '156:1029'),
  categoryPast('Categories - Past Stream', '156:1323'),
  categoryClips('Categories - Clip', '156:1512'),
  filter('Sort & Filter', '156:1713'),
  tags('Sort & Filter - Search Tags', '160:90'),
  searchTop('Search Result - Top', '174:2689'),
  searchChannels('Search Result - Channel', '174:3121'),
  searchCategories('Search Result - Categories', '174:3331'),
  searchVideos('Search Result - Past Videos', '174:3469'),
  watch('Live Watching', '95:179'),
  watchControls('Live Watching - Tapping', '109:21'),
  watchSticker('Live Watching - Chat Sticker', '111:0'),
  watchGif('Live Watching - Chat GIF', '114:42'),
  watchEmoji('Live Watching - Chat Emoji', '114:117'),
  channelPast('Info Channel - Past Stream', '116:4161'),
  channelClips('Info Channel - Clip', '116:5009'),
  channelOverview('Info Channel - Overview', '116:5187'),
  channelGallery('Info Channel - Gallery', '116:5265'),
  followers('Info Channel - Followers', '116:5325'),
  channelFollowing('Info Channel - Following', '116:5668'),
  profileSaved('Profile - Saved Stream', '147:0'),
  profileHistory('Profile - Recently Watched', '147:294'),
  settings('Profile - Setting', '147:482'),
  editProfile('Profile - Edit Info', '150:132'),
  notifications('Notification', '174:1618'),
  messages('Social - Message', '174:1879'),
  friends('Social - Friend', '174:2112');

  const AppPage(this.label, this.designId);
  final String label;
  final String designId;
}

extension AppNavigation on BuildContext {
  Future<T?> go<T>(AppPage page, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(page.name, arguments: arguments);
  void replace(AppPage page, {Object? arguments}) =>
      Navigator.of(this).pushReplacementNamed(page.name, arguments: arguments);
  void home([AppPage page = AppPage.discover]) =>
      Navigator.of(this).pushNamedAndRemoveUntil(page.name, (_) => false);
  void back() {
    Navigator.of(this).canPop() ? Navigator.of(this).pop() : home();
  }
}
