import 'package:flutter/material.dart';

ThemeData appTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final fg = dark ? Colors.white : Colors.black;
  final bg = dark ? Colors.black : Colors.white;
  final scheme = ColorScheme.fromSeed(seedColor: fg, brightness: brightness)
      .copyWith(
        primary: fg,
        onPrimary: bg,
        surface: bg,
        onSurface: fg,
        surfaceContainerHighest: dark
            ? const Color(0xff222222)
            : const Color(0xfff7f7f7),
      );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    fontFamily: 'Montserrat',
    textTheme: Typography.material2021().black.apply(
      fontFamily: 'Montserrat',
      bodyColor: fg,
      displayColor: fg,
    ),
    dividerColor: dark ? const Color(0xff333333) : const Color(0xffe2e2e2),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: fg),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: fg,
        textStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      labelStyle: TextStyle(
        color: dark ? const Color(0xff8b8b8b) : const Color(0xffaaaaaa),
        fontSize: 12,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: dark ? const Color(0xff4d4d4d) : const Color(0xffe2e2e2),
        ),
      ),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: fg)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(fg),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? fg.withValues(alpha: .35)
            : const Color(0xff888888),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: fg,
      contentTextStyle: TextStyle(color: bg, fontFamily: 'Montserrat'),
    ),
  );
}
