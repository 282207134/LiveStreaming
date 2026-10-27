import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends ChangeNotifier {
  AppController(this._preferences) {
    final raw = _preferences.getString('utubee_state');
    if (raw == null) return;
    try {
      final d = jsonDecode(raw) as Map<String, dynamic>;
      darkMode = d['dark'] as bool? ?? false;
      onboarded = d['onboarded'] as bool? ?? false;
      signedIn = d['signedIn'] as bool? ?? false;
      username = d['username'] as String? ?? username;
      email = d['email'] as String? ?? email;
      phone = d['phone'] as String? ?? phone;
      bio = d['bio'] as String? ?? bio;
      birthday = d['birthday'] as String? ?? birthday;
      online = d['online'] as bool? ?? true;
      shareActivity = d['shareActivity'] as bool? ?? true;
      notifications = d['notifications'] as bool? ?? true;
      saved = Set<String>.from(d['saved'] as List? ?? ['featured']);
      followed = Set<String>.from(
        d['followed'] as List? ?? ['LCK Global', 'T1'],
      );
      favoriteGames = Set<String>.from(
        d['games'] as List? ?? ['lol', 'dota', 'half'],
      );
      history = List<String>.from(d['history'] as List? ?? ['featured', 'lck']);
    } on FormatException {
      // An incomplete cache falls back to usable demo defaults.
    } on TypeError {
      // Older cache formats are replaced by the next update.
    }
  }
  static Future<AppController> load() async =>
      AppController(await SharedPreferences.getInstance());

  final SharedPreferences _preferences;
  bool darkMode = false, onboarded = false, signedIn = false;
  bool online = true, shareActivity = true, notifications = true;
  String username = 'trunghieu879';
  String email = 'trunghieu879@gmail.com';
  String phone = '088 - 333 - 5433';
  String bio =
      'Faker streams live on Twitch! Check out their videos, sign up ... T1 Faker.';
  String birthday = '01/07/1994';
  String query = 'league of legends';
  int sortOrder = 0;
  bool filtersActive = false;
  Set<String> tags = {'Esport', 'MOBA'};
  Set<String> saved = {'featured'};
  Set<String> followed = {'LCK Global', 'T1'};
  Set<String> favoriteGames = {'lol', 'dota', 'half'};
  List<String> history = ['featured', 'lck'];
  final List<String> sentMessages = [];
  Future<void> _pending = Future.value();

  void update(VoidCallback change) {
    change();
    notifyListeners();
    final encoded = jsonEncode({
      'dark': darkMode,
      'onboarded': onboarded,
      'signedIn': signedIn,
      'username': username,
      'email': email,
      'phone': phone,
      'bio': bio,
      'birthday': birthday,
      'online': online,
      'shareActivity': shareActivity,
      'notifications': notifications,
      'saved': saved.toList(),
      'followed': followed.toList(),
      'games': favoriteGames.toList(),
      'history': history,
    });
    _pending = _pending.then((_) async {
      await _preferences.setString('utubee_state', encoded);
    });
    unawaited(_pending);
  }

  Future<void> flush() => _pending;
  void toggleSaved(String id) => update(() {
    saved.contains(id) ? saved.remove(id) : saved.add(id);
  });
  void toggleFollow(String name) => update(() {
    followed.contains(name) ? followed.remove(name) : followed.add(name);
  });
  void recordWatch(String id) => update(() {
    history.remove(id);
    history.insert(0, id);
    if (history.length > 30) history.removeLast();
  });
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    sentMessages.add(text.trim());
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);
  static AppController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
