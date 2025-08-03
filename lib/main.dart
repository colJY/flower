import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'generated/l10n/app_localizations.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");
  runApp(const FlowerCupApp());
}

class FlowerCupApp extends StatelessWidget {
  const FlowerCupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '꽃받침',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.pink,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8B4B8),
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
