import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Features / Screens
import 'package:lifeand_care_app/features/tab1_chat/chat_view_model.dart';
import 'package:lifeand_care_app/features/tab2_map/map_view_model.dart';
import 'package:lifeand_care_app/features/tab3_health/health_view_model.dart';
import 'package:lifeand_care_app/features/tab4_settings/settings_view_model.dart';
import 'package:lifeand_care_app/data/services/history_view_model.dart';

// UI Shell
import 'package:lifeand_care_app/core/ui/navigation/main_scaffold_shell.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProxyProvider<HistoryViewModel, HealthViewModel>(
          create: (context) => HealthViewModel(context.read<HistoryViewModel>()),
          update: (context, history, health) => health ?? HealthViewModel(history),
        ),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => MapViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: const LifeAndCareApp(),
    ),
  );
}

class LifeAndCareApp extends StatelessWidget {
  const LifeAndCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life & Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF4F46E5),
          tertiary: const Color(0xFF10B981),
          surface: const Color(0xFFF9FAFB),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.copyWith(
            displayLarge: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
            titleLarge: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.3),
            bodyLarge: const TextStyle(height: 1.5),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF1F2937)),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.white,
        ),
      ),
      home: const MainScaffoldShell(),
    );
  }
}


