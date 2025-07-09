import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'services/audio_service.dart';
import 'controllers/game_controller.dart';
import 'constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => AudioService().init());
  await Get.putAsync(() => GameController().init());
  runApp(const MathFunApp());
}

class MathFunApp extends StatelessWidget {
  const MathFunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Math Fun Adventure!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.bubblegumSansTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: AppConstants.textColor,
          displayColor: AppConstants.textColor,
        ),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          primary: AppConstants.primaryColor,
          secondary: AppConstants.secondaryColor,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
