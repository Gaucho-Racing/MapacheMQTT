import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Color ACCENT_COLOR = const Color(0xFF8412fc);

Color GR_PINK = const Color(0xFFe105a3);
Color GR_PURPLE = const Color(0xFF8412fc);

// MAPBOX
const MAPBOX_LIGHT_THEME = "mapbox://styles/bharat1031/clscx8i0f004901rbco9befg6";
const MAPBOX_DARK_THEME = "mapbox://styles/bharat1031/clscx3ehu00hr01r6dxv9fjam";

// LIGHT THEME
const lightTextColor = Color(0xFF000000);
const lightBackgroundColor = Color(0xFFf9f9f9);
const lightCardColor = Color(0xFFFFFFFF);
const lightDividerColor = Color(0xFFA8A8A8);

// Dark theme
const darkTextColor = Color(0xFFE9E9E9);
const darkBackgroundColor = Color(0xFF000000);
const darkCardColor = Color(0xFF141414);
const darkDividerColor = Color(0xFF545454);

/// Dark style
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark().copyWith(
    primary: ACCENT_COLOR,
    secondary: ACCENT_COLOR,
    background: darkBackgroundColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    surface: Colors.transparent,
    surfaceTint: Colors.transparent,
  ),
  fontFamily: "Inter",
  primaryColor: ACCENT_COLOR,
  scaffoldBackgroundColor: darkBackgroundColor,
  iconTheme: const IconThemeData(color: Colors.grey),
  cardColor: darkCardColor,
  appBarTheme: const AppBarTheme(
    foregroundColor: Colors.white,
    color: darkCardColor,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
  ),
  cardTheme: CardTheme(
    color: darkCardColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      // side: BorderSide(color: Colors.grey)
    ),
  ),
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    iconColor: Colors.grey,
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: ACCENT_COLOR,
    foregroundColor: Colors.white,
  ),
  dividerColor: darkDividerColor,
  dialogBackgroundColor: darkCardColor,
  // textTheme: GoogleFonts.openSansTextTheme(ThemeData.dark().textTheme),
  popupMenuTheme: PopupMenuThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  ),
);