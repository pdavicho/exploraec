import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colores del diseño "ExploraEC Bienvenida" (Claude Design).
const _colorFondo = Color(0xFFEBFEF7);
const _colorAcentoPorDefecto = Color(0xFF006950);
const _colorTexto = Color(0xFF3D4944);
const _colorCirculoInterior = Color(0xFFDFF2EB);
const _colorBordeCirculo = Color(0xFFD4E7E0);
const _colorSombra = Color(0xFF13231F);

class BienvenidaScreenClaudeDesign extends StatelessWidget {
  const BienvenidaScreenClaudeDesign({
    super.key,
    this.colorAcento = _colorAcentoPorDefecto,
    this.onEmpezar,
  });

  /// Color del título, el ícono y el botón (el "accent" del diseño).
  final Color colorAcento;

  /// Acción del botón "Empezar".
  final VoidCallback? onEmpezar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorFondo,
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: _colorBordeCirculo),
                        boxShadow: [
                          BoxShadow(
                            color: _colorSombra.withValues(alpha: 0.08),
                            blurRadius: 24,
                            spreadRadius: -4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: _colorCirculoInterior,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.explore_outlined,
                          color: colorAcento,
                          size: 34,
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
                        color: colorAcento,
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
                          color: _colorTexto,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: colorAcento.withValues(alpha: 0.28),
                      blurRadius: 32,
                      spreadRadius: -4,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onEmpezar ?? () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorAcento,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
