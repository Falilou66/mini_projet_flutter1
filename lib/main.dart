import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:mini_projet1/screens/product_list_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion de Stock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A085)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        textTheme: GoogleFonts.montserratTextTheme(textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF16A085),
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.amber.shade800, // Couleur contrastée pour la visibilité
          foregroundColor: Colors.white,
          elevation: 4,
          hoverElevation: 6,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      home: const ProductListScreen(),
    );
  }
}
