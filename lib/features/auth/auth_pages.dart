import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_controller.dart';
import '../../core/routes.dart';
import '../../data/catalog.dart';
import '../../shared/widgets.dart';

class EntryPage extends StatefulWidget {
  const EntryPage(this.page, {super.key});
  final AppPage page;
  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  Timer? _timer;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.page == AppPage.splash && _timer == null) {
      _timer = Timer(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        final state = AppScope.of(context);
        context.replace(
          state.signedIn
              ? AppPage.discover
              : state.onboarded
              ? AppPage.welcome
              : AppPage.onboarding1,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void welcome() {
    final state = AppScope.of(context);
    state.update(() => state.onboarded = true);
    context.replace(AppPage.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.page;
    if (p == AppPage.splash) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Art.logo, width: 88, height: 88),
              const SizedBox(height: 24),
              const Text(
                'Utubee',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (p == AppPage.welcome) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 3),
                Image.asset(
                  Art.logo,
                  width: 48,
                  height: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text('Welcome to\nUtubee', style: heading(36)),
                const SizedBox(height: 40),
                AppButton(
                  'Sign In',
                  onPressed: () => context.go(AppPage.signIn),
                ),
                const SizedBox(height: 24),
                AppButton(
                  'Sign Up',
                  outlined: true,
                  onPressed: () => context.go(AppPage.signUp),
                ),
                const Spacer(flex: 4),
              ],
            ),
          ),
        ),
      );
    }
    final congratulations = p == AppPage.congratulations;
    final index = p == AppPage.onboarding2
        ? 1
        : p == AppPage.onboarding3
        ? 2
        : 0;
    final art = congratulations
        ? Art.congratulations
        : [Art.onboarding1, Art.onboarding2, Art.onboarding3][index];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, size) {
              final rect = congratulations
                  ? const Rect.fromLTWH(-200, 0, 1444, 812)
                  : [
                      const Rect.fromLTWH(87, 122, 528, 630),
                      const Rect.fromLTWH(-565, 0, 1250, 812),
                      const Rect.fromLTWH(-251, 0, 1444, 812),
                    ][index];
              return ClipRect(
                child: Stack(
                  children: [
                    Positioned(
                      left: rect.left * size.maxWidth / 375,
                      top: rect.top * size.maxHeight / 812,
                      width: rect.width * size.maxWidth / 375,
                      height: rect.height * size.maxHeight / 812,
                      child: Image.asset(art, fit: BoxFit.fill),
                    ),
                  ],
                ),
              );
            },
          ),
          if (!congratulations)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black26],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (congratulations) ...[
                    const Spacer(),
                    Center(
                      child: Text(
                        'Congratulation',
                        style: heading(28).copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Your account has been created',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 44),
                    AppButton(
                      'Explore Now',
                      light: true,
                      onPressed: () => context.replace(AppPage.chooseGames),
                    ),
                    const Spacer(),
                  ] else ...[
                    SizedBox(height: MediaQuery.sizeOf(context).height * .16),
                    Align(
                      alignment: index == 1
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        [
                          'Streaming\nEverywhere',
                          'E-Sports\nWhole World',
                          'Game\nGenres',
                        ][index],
                        style: heading(28).copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Container(width: 72, height: 2, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('3', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: welcome,
                            child: const Text(
                              'SKIP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AppButton(
                            'Get Started',
                            light: true,
                            onPressed: () => index == 2
                                ? welcome()
                                : context.replace(
                                    index == 0
                                        ? AppPage.onboarding2
                                        : AppPage.onboarding3,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage(this.page, {super.key});
  final AppPage page;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController(text: 'trunghieu1794');
  final _password = TextEditingController(text: 'streaming123');
  final _phone = TextEditingController(text: '088 - 667 - 3455');
  final _email = TextEditingController(text: 'trunghieu1794@gmail.com');
  bool _duplicate = false;
  bool get signUp => widget.page != AppPage.signIn;
  @override
  void initState() {
    super.initState();
    _duplicate = widget.page == AppPage.signUpError;
  }

  @override
  void dispose() {
    for (final c in [_username, _password, _phone, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  void submit() {
    setState(() => _duplicate = false);
    if (!_form.currentState!.validate()) return;
    if (signUp && _username.text.trim().toLowerCase() == 'trunghieu1794') {
      setState(() => _duplicate = true);
      return;
    }
    final state = AppScope.of(context);
    state.update(() {
      state.signedIn = true;
      state.onboarded = true;
      state.username = _username.text.trim();
      if (signUp) {
        state.email = _email.text.trim();
        state.phone = _phone.text.trim();
      }
    });
    signUp ? context.replace(AppPage.congratulations) : context.home();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight - 32),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        tooltip: 'Back',
                        onPressed: context.back,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          if (signUp) context.replace(AppPage.signIn);
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            color: signUp ? muted : null,
                            decoration: signUp
                                ? null
                                : TextDecoration.underline,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (!signUp) context.replace(AppPage.signUp);
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            color: signUp ? null : muted,
                            decoration: signUp
                                ? TextDecoration.underline
                                : null,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Text(
                    signUp ? 'Hello Buddy!' : 'Welcome back!',
                    style: heading(28),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _form,
                    child: Column(
                      children: [
                        TextFormField(
                          key: const ValueKey('auth_username'),
                          controller: _username,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'USERNAME',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            errorText: _duplicate
                                ? 'This username had already used'
                                : null,
                          ),
                          onChanged: (_) {
                            if (_duplicate) setState(() => _duplicate = false);
                          },
                          validator: (v) => v!.trim().length < 3
                              ? 'Use at least 3 characters'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          key: const ValueKey('auth_password'),
                          controller: _password,
                          obscureText: true,
                          textInputAction: signUp
                              ? TextInputAction.next
                              : TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'PASSWORD',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          validator: (v) => v!.length < 8
                              ? 'Use at least 8 characters'
                              : null,
                          onFieldSubmitted: (_) {
                            if (!signUp) submit();
                          },
                        ),
                        if (signUp) ...[
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'PHONE NUMBER',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            validator: validatePhone,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'EMAIL',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                            validator: validateEmail,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    signUp ? 'Sign Up' : 'Sign In',
                    key: const ValueKey('auth_submit'),
                    onPressed: submit,
                  ),
                  if (signUp)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => showInfo(
                            context,
                            'Terms and Conditions',
                            'Utubee is a local interface demo. No credentials are sent or stored. By continuing you enter the demo experience.',
                          ),
                          child: const Text(
                            'You agree with our Terms and Conditions',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: TextButton(
                        onPressed: () => context.go(AppPage.forgotPhone),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                  const Spacer(),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      signUp ? 'or sign up with' : 'or sign in with',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => showInfo(
                            context,
                            ['Google', 'Facebook', 'Instagram'][i],
                            'Social sign in requires an authentication provider. Use the demo username and password fields to continue.',
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: [
                              const Color(0xffe24c3a),
                              const Color(0xff3b5998),
                              Colors.black,
                            ][i],
                            child: i == 2
                                ? const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white,
                                  )
                                : Text(
                                    ['G', 'f'][i],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

String? validatePhone(String? value) =>
    (value ?? '').replaceAll(RegExp(r'\D'), '').length < 8
    ? 'Enter a valid phone number'
    : null;
String? validateEmail(String? value) =>
    !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value ?? '')
    ? 'Enter a valid email address'
    : null;

class RecoveryPage extends StatefulWidget {
  const RecoveryPage(this.page, {super.key});
  final AppPage page;
  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController(text: '088 - 667 - 3455');
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _digits = List.generate(4, (_) => TextEditingController());
  String? _codeError;
  @override
  void dispose() {
    for (final c in [_phone, _password, _confirm, ..._digits]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.page == AppPage.forgotPhone,
        verify = widget.page == AppPage.verifyCode;
    return Scaffold(
      appBar: PageHeader(
        phone
            ? 'Forgot Password'
            : verify
            ? 'Verify Code'
            : 'New Password',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                phone
                    ? 'Enter your phone number below to receive password reset instruction'
                    : verify
                    ? 'Please enter the 4-digit code we sent to 09xxxxxx78'
                    : 'Your new password must be different from previously used passwords',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 64),
              if (phone)
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'PHONE NUMBER',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: validatePhone,
                )
              else if (verify) ...[
                Row(
                  children: List.generate(
                    4,
                    (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == 3 ? 0 : 16),
                        child: TextField(
                          key: ValueKey('otp_$i'),
                          controller: _digits[i],
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(counterText: ''),
                          onChanged: (v) {
                            if (v.isNotEmpty && i < 3) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (_codeError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _codeError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ] else ...[
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'NEW PASSWORD',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (v) =>
                      v!.length < 8 ? 'Use at least 8 characters' : null,
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'CONFIRM NEW PASSWORD',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (v) =>
                      v != _password.text ? 'Passwords do not match' : null,
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  if (verify) ...[
                    Expanded(
                      child: AppButton(
                        'Resend Code',
                        outlined: true,
                        onPressed: () =>
                            toast(context, 'Demo verification code: 2546'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: AppButton(
                      phone
                          ? 'Continue'
                          : verify
                          ? 'Submit Code'
                          : 'Change Password',
                      onPressed: () {
                        if (!_form.currentState!.validate()) return;
                        if (verify &&
                            _digits.map((d) => d.text).join() != '2546') {
                          setState(
                            () => _codeError = 'Enter the demo code 2546',
                          );
                          return;
                        }
                        FocusScope.of(context).unfocus();
                        if (phone) {
                          context.go(AppPage.verifyCode);
                          toast(context, 'Demo verification code: 2546');
                        } else if (verify) {
                          context.go(AppPage.newPassword);
                        } else {
                          context.home(AppPage.signIn);
                          toast(
                            context,
                            'Demo password reset complete. Sign in to continue.',
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChooseGamesPage extends StatefulWidget {
  const ChooseGamesPage({super.key});
  @override
  State<ChooseGamesPage> createState() => _ChooseGamesPageState();
}

class _ChooseGamesPageState extends State<ChooseGamesPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final matches = games
        .where((g) => g.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    const order = [
      'lol',
      'counter',
      'fortnite',
      'warzone',
      'minecraft',
      'doom',
      'dota',
      'half',
      'csgo',
    ];
    matches.sort((a, b) => order.indexOf(a.id).compareTo(order.indexOf(b.id)));
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Choose the games what you love',
              style: TextStyle(fontSize: 14),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
              child: TextField(
                onChanged: (v) => setState(() => query = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search game...',
                  hintStyle: TextStyle(color: muted, fontSize: 12),
                ),
              ),
            ),
            Expanded(
              child: matches.isEmpty
                  ? const EmptyState('No games found', 'Try another game name.')
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: .63,
                          ),
                      itemCount: matches.length,
                      itemBuilder: (_, i) =>
                          GameTile(matches[i], selectable: true),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: AppButton(
                'Go to Homepage',
                onPressed: () {
                  AppScope.of(
                    context,
                  ).update(() => AppScope.of(context).onboarded = true);
                  context.home();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
