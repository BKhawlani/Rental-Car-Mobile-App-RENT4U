import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rental_car_project/screen/home_page.dart';
import 'package:rental_car_project/screen/navigator.dart';
import 'package:rental_car_project/screen/thank.dart';
import 'package:rental_car_project/screen/welcome_page.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Future.wait([
      Firebase.initializeApp(),
      EasyLocalization.ensureInitialized(),
    ]);
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('tr', 'TR'),
        Locale('ar', 'YE'),
        Locale('en', 'US'),
      ],
      path: 'assets/translation',
      fallbackLocale: const Locale('ar', 'YE'),
      startLocale: const Locale('tr', 'TR'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyappState();
}

class _MyappState extends State<MyApp> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
      debugPrint(
          user == null ? 'User signed out' : 'User signed in: ${user.email}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/home': (context) => HomePage(),
        // باقي الصفحات
      },
      localizationsDelegates: [
        ...context.localizationDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Rent a Car'.tr(),
      home: Welcome(),
      // home: _currentUser != null ? const HomePage() : const Welcome(),
    );
  }
}
