import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ExploraEcApp());
}

// Colores del sistema de diseño "Andes & Costa Discovery" (Stitch).
const colorFondo = Color(0xFFEBFEF7);
const colorPrimario = Color(0xFF006950);
const colorSobrePrimario = Color(0xFFFFFFFF);
const colorTextoSecundario = Color(0xFF3D4944);
const colorContenedor = Color(0xFFDFF2EB);

class ExploraEcApp extends StatelessWidget {
  const ExploraEcApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExploraEC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorPrimario,
          primary: colorPrimario,
          onPrimary: colorSobrePrimario,
          surface: colorFondo,
        ),
        scaffoldBackgroundColor: colorFondo,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      ),
      home: const BienvenidaScreen(),
    );
  }
}

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: colorContenedor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.explore,
                          color: colorPrimario,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ExploraEC',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 40,
                        height: 48 / 40,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.2,
                        color: colorPrimario,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        'Descubre y guarda lugares cerca de ti',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          height: 26 / 16,
                          color: colorTextoSecundario,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimario,
                    foregroundColor: colorSobrePrimario,
                    shape: const StadiumBorder(),
                    elevation: 6,
                    shadowColor: colorPrimario.withValues(alpha: 0.4),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Empezar'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
