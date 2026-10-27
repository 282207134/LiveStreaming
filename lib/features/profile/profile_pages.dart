import 'package:flutter/material.dart';
import '../../core/app_controller.dart';
import '../../core/routes.dart';
import '../../data/catalog.dart';
import '../../shared/widgets.dart';
import '../auth/auth_pages.dart';
import '../browse/browse_pages.dart';
import '../channel/channel_pages.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.history = false});
  final bool history;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool history = widget.history;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = (history ? state.history : state.saved.toList())
        .map(streamById)
        .toList();
    return HomeFrame(
      title: 'Profile',
      selected: 3,
      trailing: IconButton(
        tooltip: 'Settings',
        onPressed: () => context.go(AppPage.settings),
        icon: const Icon(Icons.settings_outlined, size: 24),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          const Center(child: Avatar(Art.profile, size: 80)),
          const SizedBox(height: 20),
          Center(child: Text(state.username, style: heading(20))),
          const SizedBox(height: 8),
          Center(
            child: Text(
              state.online ? 'Online' : 'Offline',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ProfileStats(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: AppButton(
              'Live Your Channel',
              onPressed: () => showInfo(
                context,
                'Live your channel',
                'The broadcast setup is ready for a streaming service integration. This UI demo does not publish a live broadcast.',
              ),
            ),
          ),
          LineTabs(
            labels: const ['Saved Stream', 'Recently Watched'],
            selected: history ? 1 : 0,
            onChanged: (i) => setState(() => history = i == 1),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            EmptyState(
              history ? 'Your history is empty' : 'No saved streams',
              history
                  ? 'Watch a stream to find it here.'
                  : 'Tap the heart in a stream to save it for later.',
            )
          else if (history)
            ...List.generate(
              items.length,
              (i) => PastVideoRow(items[i], index: i),
            )
          else
            StreamRail(items, live: false),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: const PageHeader('SETTING'),
      body: ListView(
        children: [
          const Divider(height: 1),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            leading: const Avatar(Art.profile, size: 48),
            title: Text(state.username, style: heading(16)),
            subtitle: Text(
              state.online ? 'Online' : 'Offline',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: TextButton(
              onPressed: () => context.go(AppPage.editProfile),
              child: const Text(
                'EDIT',
                style: TextStyle(letterSpacing: 1.5, fontSize: 12),
              ),
            ),
          ),
          const Divider(height: 1),
          const SectionTitle('Connect Social'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                for (final name in ['Facebook', 'Google'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppButton(
                      name,
                      outlined: true,
                      onPressed: () => showInfo(
                        context,
                        'Connect $name',
                        'Connect an OAuth provider to enable $name sign in. Local demo mode is active.',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SectionTitle('General Setting'),
          _toggle(
            context,
            'Online',
            state.online,
            (v) => state.update(() => state.online = v),
          ),
          _toggle(
            context,
            'Share my activity',
            state.shareActivity,
            (v) => state.update(() => state.shareActivity = v),
          ),
          _toggle(
            context,
            'Notification',
            state.notifications,
            (v) => state.update(() => state.notifications = v),
          ),
          _toggle(
            context,
            'Dark mode',
            state.darkMode,
            (v) => state.update(() => state.darkMode = v),
            key: const ValueKey('dark_mode'),
          ),
          _row(
            context,
            Icons.videocam_off,
            'Channel setting',
            () => context.go(AppPage.editProfile),
          ),
          _row(
            context,
            Icons.people,
            'Friends',
            () => context.go(AppPage.friends),
          ),
          _row(
            context,
            Icons.language,
            'Language',
            () => showInfo(
              context,
              'Language',
              'English · the interface follows the original Pixso copy.',
            ),
          ),
          _row(
            context,
            Icons.article,
            'Term & Conditions',
            () => showInfo(
              context,
              'Terms & Conditions',
              'Utubee is a local prototype. All stream thumbnails and content are design reference material. Authentication, payments and broadcasting are not connected.',
            ),
          ),
          _row(
            context,
            Icons.menu_book,
            'FAQ',
            () => showInfo(
              context,
              'FAQ',
              'How do I save a stream? Tap the heart on the player.\n\nHow do I change appearance? Toggle Dark mode here.\n\nWhat is the verification code? The local demo code is 2546.',
            ),
          ),
          _row(
            context,
            Icons.info,
            'About',
            () => showInfo(
              context,
              'Utubee 1.0.0',
              'Live streaming UI built with Flutter from the Pixso Light / Dark design. Explore games, follow creators and join the conversation.',
            ),
          ),
          _row(context, Icons.logout, 'Log out', () {
            state.update(() => state.signedIn = false);
            context.home(AppPage.welcome);
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _toggle(
    BuildContext context,
    String label,
    bool value,
    ValueChanged<bool> change, {
    Key? key,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: .7),
        ),
      ),
      child: SwitchListTile(
        key: key,
        contentPadding: EdgeInsets.zero,
        title: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        value: value,
        onChanged: change,
        dense: true,
      ),
    ),
  );
  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback action,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: .7),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, size: 22),
        title: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right, color: muted, size: 20),
        onTap: action,
      ),
    ),
  );
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _form = GlobalKey<FormState>();
  final Map<String, TextEditingController> _fields = {};
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fields.isNotEmpty) return;
    final state = AppScope.of(context);
    for (final e in {
      'name': state.username,
      'email': state.email,
      'phone': state.phone,
      'bio': state.bio,
      'birthday': state.birthday,
    }.entries) {
      _fields[e.key] = TextEditingController(text: e.value);
    }
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  void save() {
    if (!_form.currentState!.validate()) return;
    final state = AppScope.of(context);
    state.update(() {
      state.username = _fields['name']!.text.trim();
      state.email = _fields['email']!.text.trim();
      state.phone = _fields['phone']!.text.trim();
      state.bio = _fields['bio']!.text.trim();
      state.birthday = _fields['birthday']!.text;
    });
    FocusScope.of(context).unfocus();
    context.back();
    toast(context, 'Profile saved');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PageHeader(
      'EDIT INFO',
      actions: [
        TextButton(
          key: const ValueKey('save_profile'),
          onPressed: save,
          child: const Text(
            'SAVE',
            style: TextStyle(fontSize: 11, letterSpacing: 1),
          ),
        ),
      ],
    ),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(child: Avatar(Art.profile, size: 80)),
          const SizedBox(height: 28),
          Text('YOUR BIO', style: heading(14)),
          TextFormField(
            controller: _fields['bio'],
            maxLines: 3,
            style: const TextStyle(fontSize: 13, height: 1.6),
            decoration: const InputDecoration(
              hintText: 'Tell viewers about yourself',
            ),
          ),
          const SizedBox(height: 28),
          Text('PERSONAL INFORMATION', style: heading(14)),
          const SizedBox(height: 20),
          TextFormField(
            key: const ValueKey('profile_name'),
            controller: _fields['name'],
            decoration: const InputDecoration(
              labelText: 'USER NAME',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            validator: (v) =>
                v!.trim().length < 3 ? 'Use at least 3 characters' : null,
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: 'streaming123',
            obscureText: true,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'PASSWORD',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: TextButton(
                onPressed: () => context.go(AppPage.forgotPhone),
                child: const Text('CHANGE', style: TextStyle(fontSize: 10)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _fields['email'],
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'EMAIL',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            validator: validateEmail,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _fields['phone'],
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'PHONE NUMBER',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            validator: validatePhone,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _fields['birthday'],
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'DATE OF BIRTH',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: Icon(Icons.calendar_month, size: 20),
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(1994, 7, 1),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                _fields['birthday']!.text =
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
              }
            },
          ),
        ],
      ),
    ),
  );
}
